package rluacompiler;

#if (macro || rlua_runtime)

import reflaxe.ReflectCompiler;
import reflaxe.preprocessors.ExpressionPreprocessor;

class CompilerInit {
	public static function Start() {
		#if !eval
		Sys.println("CompilerInit.Start can only be called from a macro context.");
		return;
		#end

		#if (haxe_ver < "4.3.0")
		Sys.println("Reflaxe/Lua requires Haxe version 4.3.0 or greater.");
		return;
		#end

		ReflectCompiler.AddCompiler(new Compiler(), {
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
			reservedVarNames: reservedNames(),
			targetCodeInjectionName: "__lua__",
			// manualDCE: true,
			trackUsedTypes: true
		});
	}

	static function reservedNames() {
		return [];
	}
}

#end
