package rluacompiler.subcompilers;

#if (macro || rlua_runtime)

import haxe.macro.Type;

// Import Reflaxe types
import reflaxe.DirectToStringCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;

using StringTools;

class Fields extends SubCompiler {
	
	private function indent(depth: Int): String {
		return [for (_ in 0...depth) "\t"].join("");
	}
	
	private function indentLines(str: String, depth: Int): String {
		if (depth == 0) return str;
		var lines = str.split("\n");
		return lines.map(line -> line.length > 0 ? indent(depth) + line : line).join("\n");
	}

	public function compileStaticImpl(varf: ClassVarData): Null<String>
	{
		var output = '${varf.classType.name}.${varf.field.name}';
		if (varf.field.expr() != null)
			output += ' = ${main.expressionsSubCompiler.compileExpressionImpl(varf.field.expr(), 0)}';
		return output + "\n";
	}

	public function compileFuncImpl(func: ClassFuncData): Null<String>
	{
		var output = "";
		var argsStr = "";
		var clsName = func.classType.name;
		var funcName = func.field.name == "new" ? "__constructor" : func.field.name;

		for (arg in func.args)
			argsStr += arg.getName() + (func.args.indexOf(arg) < func.args.length - 1 ? ", " : "");
		
		output += 'function ${clsName}${isDotMethod(func) ? "." : ":"}${funcName}(${argsStr})\n\t';
		
		// Compile the function body with proper indentation
		var bodyCode = "";
		
		if (func.field.meta.has(":functionCode"))
		{
			var code = switch (func.field.meta.extract(":functionCode")[0].params[0].expr) {
    			case EConst(CString(s)): s;
    			case _: throw "Expected a string literal";
			};
			bodyCode = code;
		}
		else
		{
			if (func.expr != null)
				bodyCode = main.expressionsSubCompiler.compileExpressionImpl(func.expr, 0);
		}

		output += bodyCode.replace("\n", "\n\t") + '\n';
		output += 'end\n';

		return output;
	}

	public function isDotMethod(func: ClassFuncData): Bool
	{
		return func.isStatic || func.field.meta.has(":luaDotMethod");
	}
}

#end