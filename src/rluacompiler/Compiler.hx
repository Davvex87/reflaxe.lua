package rluacompiler;

#if (macro || rlua_runtime)

// Make sure this code only exists at compile-time.
import rluacompiler.subcompilers.*;

// Import relevant Haxe macro types.
import haxe.macro.Type;

// Import Reflaxe types
import reflaxe.DirectToStringCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;

/**
	The class used to compile the Haxe AST into your target language's code.

	This must extend from `BaseCompiler`. `PluginCompiler<T>` is a child class
	that provides the ability for people to make plugins for your compiler.
**/
class Compiler extends DirectToStringCompiler {

	public var classesSubCompiler:Classes;
	public var fieldsSubCompiler:Fields;
	public var expressionsSubCompiler:Expressions;
	public var enumsSubCompiler:Enums;

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
	public function compileClassImpl(classType: ClassType, varFields: Array<ClassVarData>, funcFields: Array<ClassFuncData>): Null<String>
	{
		return classesSubCompiler.compileClassImpl(classType, varFields, funcFields);
	}

	/**
		Works just like `compileClassImpl`, but for Haxe enums.
		Since we're returning `null` here, all Haxe enums are ignored.
		
		https://api.haxe.org/haxe/macro/EnumType.html
	**/
	public function compileEnumImpl(enumType: EnumType, constructs: Array<EnumOptionData>): Null<String>
	{
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
	public function compileExpressionImpl(expr: TypedExpr, topLevel: Bool): Null<String>
	{
		return expressionsSubCompiler.compileExpressionImpl(expr, 0);
	}
}

#end
