package rluacompiler;

import reflaxe.BaseCompiler;
import reflaxe.BaseCompiler.BaseCompilerOptions;
#if (macro || rlua_runtime)

import reflaxe.ReflectCompiler;
import reflaxe.preprocessors.ExpressionPreprocessor;

class CompilerInit {

	public static final COMPILER_CLASS:Class<Dynamic> = Compiler;
	public static final COMPILER_OPTIONS:BaseCompilerOptions = {
			expressionPreprocessors: [
				SanitizeEverythingIsExpression({
					convertIncrementAndDecrementOperators: true,
					convertNullCoalescing: true,
					setUninitializedVariablesToNull: true
				}),
				PreventRepeatVariables({}),
				RemoveSingleExpressionBlocks,
				RemoveConstantBoolIfs,
				RemoveUnnecessaryBlocks,
				RemoveReassignedVariableDeclarations,
				RemoveLocalVariableAliases,
				RemoveTemporaryVariables(AllTempVariables),
				MarkUnusedVariables,
			],
			fileOutputExtension: ".lua",
			outputDirDefineName: "lua-output",
			fileOutputType: FilePerModule,
			reservedVarNames: [],
			targetCodeInjectionName: "__lua__",
			manualDCE: false,
			trackUsedTypes: true
		};

	public static var compiler:Compiler;
	
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

		compiler = Type.createInstance(COMPILER_CLASS, []);
		ReflectCompiler.AddCompiler(compiler, COMPILER_OPTIONS);
	}
}

#end
