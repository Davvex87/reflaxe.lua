package rluacompiler;

#if (macro || rlua_runtime)
import reflaxe.ReflectCompiler;
import reflaxe.preprocessors.ExpressionPreprocessor;
import rluacompiler.preprocessors.implementations.*;
import reflaxe.BaseCompiler;
import reflaxe.BaseCompiler.BaseCompilerOptions;
import rluacompiler.utils.LuaVUtils;
import haxe.macro.Context;
import sys.io.Process;
import haxe.Template;
import haxe.io.Path;
import sys.io.File;

using StringTools;

class CompilerInit
{
	public static final COMPILER_CLASS:Class<Dynamic> = Compiler;
	public static final COMPILER_OPTIONS:BaseCompilerOptions = {
		expressionPreprocessors: [
			Custom(new IteratorFix([{abstractModule: "haxe.ds.Map"}])),
			SanitizeEverythingIsExpression({
				convertIncrementAndDecrementOperators: true,
				convertNullCoalescing: false, // true
				setUninitializedVariablesToNull: true
			}),
			PreventRepeatVariables({}),
			RemoveSingleExpressionBlocks,
			RemoveConstantBoolIfs,
			RemoveUnnecessaryBlocks,
			RemoveReassignedVariableDeclarations,
			RemoveLocalVariableAliases,
			// RemoveTemporaryVariables(AllOneUseVariables),
			RemoveTemporaryVariables(AllTempVariables),
			MarkUnusedVariables,
			RemovePureExpressions,
			Custom(new ConvertBitwiseOperators(LuaVUtils.bitFuncPattern, LuaVUtils.bitFuncField)),
			Custom(new Lua51LoopContinuePatch()),
			Custom(new LuaMultiReturnPatch()),
			Custom(new ExprBinopFix()),
			Custom(new ArrayLengthFix())
		],
		fileOutputExtension: ".lua",
		outputDirDefineName: "lua-output",
		fileOutputType: Manual,
		reservedVarNames: [
			"and",
			"break",
			"do",
			"else",
			"elseif",
			"end",
			"false",
			"for",
			"function",
			"if",
			"in",
			"local",
			"nil",
			"not",
			"or",
			"repeat",
			"return",
			"then",
			"true",
			"until",
			"while"
		],
		targetCodeInjectionName: "__lua__",
		manualDCE: false,
		trackUsedTypes: true,
		ignoreTypes: [],
		convertStaticVarExpressionsToFunctions: false
	};

	public static var compiler:Compiler;

	static var libPath:String;

	public static function Start()
	{
		#if !eval
		Sys.println("CompilerInit.Start can only be called from a macro context.");
		return;
		#end

		#if (haxe_ver < "4.3.0")
		Sys.println("Reflaxe/Lua requires Haxe version 4.3.0 or greater.");
		return;
		#end

		libPath = haxelib(resolve -> "reflaxe.lua", "reflaxe.lua");

		var runtimeFile:String = Context.definedValue("runtime_config") ?? "$$haxelib(reflaxe.lua)/src/resources/HxRuntime_noWrapper.json";
		var parsedPath = new Template(runtimeFile).execute({}, CompilerInit);

		var runtimeConfig:RuntimeConfig = RuntimeConfig.fromFile(parsedPath);

		compiler = Type.createInstance(COMPILER_CLASS, []);
		compiler.runtimeConfig = runtimeConfig;
		ReflectCompiler.AddCompiler(compiler, COMPILER_OPTIONS);
	}

	public static function getResource(path:String):String
	{
		var fullPath = Path.join([libPath, "src", "resources", path]);
		return File.getContent(fullPath);
	}

	@:keep static function haxelib(resolve:String->Dynamic, lib:String):String
	{
		if (lib == "reflaxe.lua" && libPath != null)
			return libPath;

		var process = new Process("haxelib", ["libpath", lib]);
		if (process.exitCode() != 0)
			throw 'haxelib libpath failed for library $lib: ${process.stderr.readAll().toString()}';
		var out = process.stdout.readAll().toString().replace("\n", "").replace("\r", "").trim();
		return Path.normalize(out);
	}
}
#end
