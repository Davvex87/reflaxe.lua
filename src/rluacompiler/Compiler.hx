package rluacompiler;

#if (macro || rlua_runtime)
import rluacompiler.utils.ModuleUtils;
import rluacompiler.subcompilers.*;
import haxe.macro.Type;
import reflaxe.DirectToStringCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;
import rluacompiler.utils.TypeExtractor;
import haxe.macro.Context;
import reflaxe.output.OutputManager;
import reflaxe.output.StringOrBytes;
import rluacompiler.resources.*;

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
	public var modulesSubCompiler:Modules;

	public var typesPerModule:Map<String, Array<BaseType>> = new Map<String, Array<BaseType>>();
	public var usedTypesPerModule:Map<String, Map<String, Array<BaseType>>> = new Map<String, Map<String, Array<BaseType>>>();
	public var customImports:Map<String, Array<BaseType>> = new Map<String, Array<BaseType>>();
	public var topLevelCode:Map<String, Array<String>> = new Map<String, Array<String>>();

	public var importWrapperClassStr:Null<String> = null;

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
				var found = false;
				for (m => tar in st)
				{
					for (t in tar)
						if (t.equals(ut))
						{
							found = true;
							break;
						}
				}

				if (!found)
				{
					if (!st.exists(ut.module))
					{
						st.set(ut.module, []);
					}
					st.get(ut.module).push(ut);
				}
			}
		}
	}

	public function new()
	{
		classesSubCompiler = new Classes(this);
		fieldsSubCompiler = new Fields(this);
		expressionsSubCompiler = new Expressions(this);
		enumsSubCompiler = new Enums(this);
		modulesSubCompiler = new Modules(this);

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

		if (classType.superClass != null)
			addTypesToMod(classType.module, [classType.superClass.t.get()]);

		if (classType.interfaces.length > 0)
			for (iface in classType.interfaces)
				addTypesToMod(classType.module, [iface.t.get()]);

		for (varf in varFields)
		{
			var e = varf.field.expr();
			if (e != null)
				addTypesToMod(classType.module, TypeExtractor.extractAllUsedTypes(e));
		}
		for (funcf in funcFields)
		{
			var e = funcf.expr;
			if (e != null)
				addTypesToMod(classType.module, TypeExtractor.extractAllUsedTypes(e));
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

		final pkgWrapperClass:Null<IPkgWrapper> =
			{
				trace(importWrapperClassStr);
				if (importWrapperClassStr == null)
					null;
				else if (importWrapperClassStr == "1")
					Type.createInstance(rluacompiler.resources.HxPkgWrapper, []);
				else
				{
					var cls = Type.resolveClass(importWrapperClassStr);
					trace(cls);
					if (cls == null)
						throw 'Could not resolve class "$importWrapperClassStr"';
					Type.createInstance(cls, []);
				}
			}

		for (moduleId => outputList in files)
		{
			final head:Array<StringOrBytes> = [];

			final decls = typesPerModule.get(moduleId) ?? [];
			head.push("local " + decls.map(t -> t.name).join(", ") + " = " + decls.map(t -> "{}").join(", ") + ";");
			if (pkgWrapperClass != null)
			{
				head.push(pkgWrapperClass.requireCode(moduleId));
				head.push(pkgWrapperClass.registerCode(moduleId, decls));
			}
			else
				head.push('package.loaded["${moduleId}"] = {${decls.map(t -> t.name).join(", ")}};');

			final t = usedTypesPerModule.get(moduleId) ?? new Map<String, Array<BaseType>>();
			head.push(modulesSubCompiler.compileImports(moduleId, t, files, typesPerModule, pkgWrapperClass));

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
			finalOutputList.push('\nreturn {${decls.map(t -> t.name).join(", ")}}');

			output.saveFile(output.getFileName(moduleId.replace(".", "/")), OutputManager.joinStringOrBytes(finalOutputList));
		}

		if (pkgWrapperClass != null)
			output.saveFile(pkgWrapperClass.filePath, pkgWrapperClass.wrapperCode);
	}
}
#end
