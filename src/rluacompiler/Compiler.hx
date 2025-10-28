package rluacompiler;

#if (macro || rlua_runtime)
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

using reflaxe.helpers.BaseTypeHelper;
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

	function addTypesToMod(baseModule:String, types:Array<BaseType>)
	{
		var st = usedTypesPerModule.get(baseModule);
		for (ut in types)
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

		var data = classesSubCompiler.compileClassImpl(classType, varFields, funcFields);

		// if (data == null)
		//	return null;

		if (!usedTypesPerModule.exists(classType.module))
			usedTypesPerModule.set(classType.module, new Map<String, Array<BaseType>>());

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

	override public function generateFilesManually() @:privateAccess {
		output.ensureOutputDirExists();

		final files:Map<String, Array<StringOrBytes>> = [];
		final types:Array<BaseType> = [];
		for (c in generateOutputIterator())
		{
			trace(c.baseType.module);
			trace(c.baseType.name);
			final mid = c.baseType.module;
			final filename = output.overrideFileName(mid, c);
			if (!files.exists(filename))
				files[filename] = [];

			final f = files[filename];
			if (f != null)
				f.push(c.data);
		}

		for (moduleId => outputList in files)
		{
			var head:Array<StringOrBytes> = [];

			var decls = typesPerModule.get(moduleId) ?? [];
			head.push("local " + decls.map(t -> t.name).join(", ") + " = " + decls.map(t -> "{}").join(", ") + "");

			head.push('package.loaded["${moduleId}"] = {${decls.map(t -> t.name).join(", ")}}');

			var t = usedTypesPerModule.get(moduleId) ?? new Map<String, Array<BaseType>>();
			head.push(modulesSubCompiler.compileImports(moduleId, t));

			var finalOutputList = head.concat(outputList);

			finalOutputList.push('\nreturn {${decls.map(t -> t.name).join(", ")}}');

			output.saveFile(output.getFileName(moduleId.replace(".", "/")), OutputManager.joinStringOrBytes(finalOutputList));
		}
	}
}
#end
