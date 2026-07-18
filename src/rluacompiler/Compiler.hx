package rluacompiler;

#if (macro || rlua_runtime)
import rluacompiler.utils.ModuleUtils;
import rluacompiler.subcompilers.*;
import reflaxe.DirectToStringCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;
import rluacompiler.utils.UsedTypeCollector;
import haxe.macro.Context;
import reflaxe.output.OutputManager;
import reflaxe.output.StringOrBytes;
import rluacompiler.resources.*;
import rluacompiler.resources.HxPkgWrapper;
import rluacompiler.resources.RblxPkgWrapper;
import haxe.macro.Type.ClassType;
import haxe.macro.Type.EnumType;
import haxe.macro.Type.BaseType;
import haxe.macro.Type.TypedExpr;
import haxe.io.Path;
import sys.io.File;
import haxe.Template;

using reflaxe.helpers.BaseTypeHelper;
using reflaxe.helpers.TypedExprHelper;
using StringTools;

/**
	The class used to compile the Haxe AST into your target language's code.

	This must extend from `BaseCompiler`. `PluginCompiler<T>` is a child class
	that provides the ability for people to make plugins for your compiler.
**/
class Compiler extends DirectToStringCompiler
{
	public var classesSubCompiler:Classes;
	public var fieldsSubCompiler:Fields;
	public var expressionsSubCompiler:Expressions;
	public var enumsSubCompiler:Enums;

	public var typesPerModule:Map<String, Array<BaseType>> = new Map<String, Array<BaseType>>();
	public var usedTypesPerModule:Map<String, Map<String, Array<BaseType>>> = new Map<String, Map<String, Array<BaseType>>>();
	public var customImports:Map<String, Array<BaseType>> = new Map<String, Array<BaseType>>();
	public var topLevelCode:Map<String, Array<String>> = new Map<String, Array<String>>();

	// public var importWrapperClassStr:Null<String> = null;
	public var runtimeConfig:RuntimeConfig;

	function addTypesToMod(baseModule:String, types:Array<BaseType>)
	{
		var st = usedTypesPerModule.get(baseModule);
		var ui:Array<BaseType> = customImports.get(baseModule) ?? [];
		for (ut in types)
		{
			if (ut.meta.has(":customImport"))
			{
				if (!ui.contains(ut))
					ui.push(ut);
			}
			else
			{
				var mod = ut.module;
				if (!st.exists(mod))
					st.set(mod, []);
				var arr = st.get(mod);
				var found = false;
				for (t in arr)
					if (t.equals(ut))
					{
						found = true;
						break;
					}
				if (!found)
					arr.push(ut);
			}
		}
	}

	public function new()
	{
		classesSubCompiler = new Classes(this);
		fieldsSubCompiler = new Fields(this);
		expressionsSubCompiler = new Expressions(this);
		enumsSubCompiler = new Enums(this);

		super();
	}

	/**
		This is the function from the BaseCompiler to override to compile Haxe classes.
		Given the haxe.macro.ClassType and its variables and fields, return the output String.
		If `null` is returned, the class is ignored and nothing is compiled for it.

		https://api.haxe.org/haxe/macro/ClassType.html
	**/
	public function compileClassImpl(classType:ClassType, varFields:Array<ClassVarData>, funcFields:Array<ClassFuncData>):Null<String>
	{
		if (!typesPerModule.exists(classType.module))
			typesPerModule.set(classType.module, []);
		typesPerModule.get(classType.module).push(classType);

		// if (!classType.meta.has("keep") && ModuleUtils.isFullExternImpl(classType, varFields, funcFields))
		//	return null;

		if (!topLevelCode.exists(classType.module))
			topLevelCode.set(classType.module, []);

		for (funcf in funcFields)
		{
			if (funcf.field.meta.has(":topLevelCall"))
			{
				if (!funcf.isStatic)
					throw "Top-level calls can only be used on static functions.";
				var e = funcf.expr;
				if (e != null)
					topLevelCode.get(classType.module).push('${classType.name}.${funcf.field.name}()');
			}
			else if (funcf.field.meta.has(":topLevelCode"))
			{
				if (!funcf.isStatic)
					throw "Top-level code can only be defined by static functions.";
				var e = funcf.expr;
				if (e != null)
					topLevelCode.get(classType.module).push(expressionsSubCompiler.compileExpressionImpl(e, 0, null));
			}
		}

		var data = classesSubCompiler.compileClassImpl(classType, varFields, funcFields);

		if (data == null)
			return null;

		if (!usedTypesPerModule.exists(classType.module))
			usedTypesPerModule.set(classType.module, new Map<String, Array<BaseType>>());
		if (!customImports.exists(classType.module))
			customImports.set(classType.module, []);

		// FIXME: This does not appear to work for the PosException class
		if (classType.superClass != null)
			addTypesToMod(classType.module, [classType.superClass.t.get()]);

		if (classType.interfaces.length > 0)
			for (iface in classType.interfaces)
				addTypesToMod(classType.module, [iface.t.get()]);

		for (varf in varFields)
		{
			var e = varf.field.expr();
			if (e != null)
				addTypesToMod(classType.module, UsedTypeCollector.extract(e).getTypes());
		}
		for (funcf in funcFields)
		{
			var e = funcf.expr;
			if (e != null)
				addTypesToMod(classType.module, UsedTypeCollector.extract(e).getTypes());
		}

		return data;
	}

	/**
		Works just like `compileClassImpl`, but for Haxe enums.
		Since we're returning `null` here, all Haxe enums are ignored.

		https://api.haxe.org/haxe/macro/EnumType.html
	**/
	public function compileEnumImpl(enumType:EnumType, constructs:Array<EnumOptionData>):Null<String>
	{
		if (!typesPerModule.exists(enumType.module))
			typesPerModule.set(enumType.module, []);
		typesPerModule.get(enumType.module).push(enumType);

		return enumsSubCompiler.compileEnumImpl(enumType, constructs);
	}

	/**
		This is the final required function.
		It compiles the expressions generated from Haxe.

		PLEASE NOTE: to recusively compile sub-expressions:
			BaseCompiler.compileExpression(expr: TypedExpr): Null<String>
			BaseCompiler.compileExpressionOrError(expr: TypedExpr): String

		https://api.haxe.org/haxe/macro/TypedExpr.html
	**/
	public function compileExpressionImpl(expr:TypedExpr, topLevel:Bool):Null<String>
	{
		return expressionsSubCompiler.compileExpressionImpl(expr, 0);
	}

	public function compileNativeVariableCodeMetaWithAccessor(fieldExpr:TypedExpr, varCpp:Null<String> = null, accessor:Null<String> = null):Null<String>
	{
		final declaration = fieldExpr.getDeclarationMeta();
		if (declaration == null)
		{
			return null;
		}
		final meta = declaration.meta;
		final data = meta != null ? extractStringFromMeta(meta, ":nativeVariableCode") : null;
		if (data != null)
		{
			final code = data.code;
			var result = code;

			if (code.contains("{this}"))
			{
				final thisExpr = declaration.thisExpr != null ? compileNFCThisExpression(declaration.thisExpr, declaration.meta) : null;
				if (thisExpr == null)
				{
					if (declaration.thisExpr == null)
					{
						#if eval
						Context.error("Cannot use {this} on @:nativeVariableCode meta for constructors.", data.entry.pos);
						#end
					}
					else
					{
						onExpressionUnsuccessful(fieldExpr.pos);
					}
				}
				else
				{
					result = result.replace("{this}", thisExpr);
				}
			}

			if (varCpp != null && code.contains("{var}"))
			{
				result = result.replace("{var}", varCpp);
			}

			if (accessor != null && code.contains("{accessor}"))
			{
				result = result.replace("{accessor}", accessor);
			}

			return result;
		}

		return null;
	}

	override public function generateFilesManually():Void @:privateAccess {
		output.ensureOutputDirExists();

		final files:Map<String, Array<StringOrBytes>> = [];
		final types:Array<BaseType> = [];
		for (c in generateOutputIterator())
		{
			final mid = c.baseType.module;
			final filename = output.overrideFileName(mid, c);
			if (!files.exists(filename))
				files[filename] = [];

			final f = files[filename];
			if (f != null)
				f.push(c.data);
		}

		var sourceHeader = Context.definedValue("source_header");

		if (sourceHeader == null || sourceHeader.length < 1)
			sourceHeader = "";

		var mainClass = haxe.macro.Compiler.getConfiguration().mainClass;
		var entryWrapper:Null<String> = Context.definedValue("entry_wrapper");

		var entryCode:Null<String> = null;
		var mainClassId:Null<String> = null;
		if (mainClass != null)
		{
			mainClassId = mainClass.pack.concat([mainClass.name]).join(".");
			var entryCodeSample = CompilerInit.getResource("_hx_entry.lua");
			var template = new Template(entryCodeSample);
			entryCode = template.execute({
				moduleid: mainClassId,
			});
		}

		for (moduleId => outputList in files)
		{
			final isMainModule = entryWrapper == null
				&& mainClass != null
				&& mainClass.pack.concat([mainClass.name]).join(".") == moduleId;

			final head:Array<StringOrBytes> = ['-- $sourceHeader'];

			final decls = typesPerModule.get(moduleId) ?? [];
			head.push("local " + decls.map(t -> t.name).join(", ") + " = " + decls.map(t -> "{}").join(", ") + ";");
			head.push(runtimeConfig.resolveRequire());
			head.push(runtimeConfig.resolveRegister(moduleId, decls.map(t -> t.name)));

			final usedTypes = usedTypesPerModule.get(moduleId) ?? new Map<String, Array<BaseType>>();

			var imports:Array<String> = [];
			for (m => tar in usedTypes)
			{
				if (moduleId == m)
					continue;
				if (!files.exists(m))
					continue;
				var ts = typesPerModule.get(m);
				if (ts == null || ts.length == 0)
					continue;
				imports.push(runtimeConfig.resolveImport(ts.map(t ->
				{
					if (t.meta.has(":customImport"))
						return "_";
					return t.name;
				}), m));
			}

			head.push(imports.join("\n"));

			for (_ => cls in customImports.get(moduleId) ?? [])
			{
				final e = cls.meta.extract(":customImport")[0].params[0].expr;
				var imp = switch (e)
				{
					case EConst(c):
						switch (c)
						{
							case CString(s):
								s;
							default:
								"_";
						}
					default:
						cls.name;
				};
				head.push('local ${cls.name} = ${imp}\n');
			}

			final finalOutputList = head.concat(outputList);

			for (code in topLevelCode.get(moduleId) ?? [])
			{
				finalOutputList.push(code + "\n");
			}

			if (isMainModule)
			{
				if (!usedTypes.exists("haxe.EntryPoint"))
					finalOutputList.push(runtimeConfig.resolveImport(["EntryPoint"], "haxe.EntryPoint"));
				finalOutputList.push(entryCode);
			}
			else
				finalOutputList.push('\nreturn {${decls.map(t -> t.name).join(", ")}}');

			output.saveFile(output.getFileName(moduleId.replace(".", "/")), OutputManager.joinStringOrBytes(finalOutputList));
		}

		if (entryWrapper != null && mainClass != null)
		{
			var initCodeSample = CompilerInit.getResource("_hx_init.lua");
			var template = new Template(initCodeSample);
			var initOut = template.execute({
				requirecode: runtimeConfig.resolveRequire(),
				importcode: runtimeConfig.resolveImport([mainClass.name], mainClassId) + "\n" + runtimeConfig.resolveImport(["EntryPoint"], "haxe.EntryPoint"),
				entrycode: entryCode
			});

			output.saveFile(entryWrapper, initOut);
		}

		var runtimeLuaScriptPath = runtimeConfig.getRuntimePath();
		var runtimeLuaScriptContent = File.getContent(runtimeLuaScriptPath);
		output.saveFile(Path.withoutDirectory(runtimeLuaScriptPath), runtimeLuaScriptContent);
	}
}
#end
