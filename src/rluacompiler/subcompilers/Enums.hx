package rluacompiler.subcompilers;

#if (macro || rlua_runtime)

import haxe.macro.Type;

// Import Reflaxe types
import reflaxe.DirectToStringCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;

class Enums extends SubCompiler {

	public function compileEnumImpl(enumType: EnumType, constructs: Array<EnumOptionData>): Null<String>
	{
		if (constructs.length == 0)
			return null;

		var output = "";

		output += '${enumType.name} = setmetatable({\n';
		
		var i = 0;
		for (constr in constructs)
		{
			output += '\t${constr.name} = setmetatable(' + 
				'{index=${i++}},' +
				'{__tostring=function(self) return "${enumType.name}.${constr.name}" end}),\n';
		}

		output += '}, {\n\t__tostring = function(self)\n\t\treturn "Enum<${enumType.name}>"\n\tend\n})\n';
		output += '${enumType.name}.__index = ${enumType.name}\n';
		output += "\n";

		return output;
	}
}

#end