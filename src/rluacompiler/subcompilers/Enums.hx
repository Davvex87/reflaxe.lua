package rluacompiler.subcompilers;

#if (macro || rlua_runtime)
import reflaxe.DirectToStringCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;
import haxe.macro.Type;

class Enums extends SubCompiler
{
	public function compileEnumImpl(enumType:EnumType, constructs:Array<EnumOptionData>):Null<String>
	{
		if (constructs.length == 0)
			return null;

		var output = "";

		var i = 0;
		for (constr in constructs)
		{
			if (constr.args.length == 0)
				output += '${enumType.name}.${constr.name} = setmetatable('
					+ '{_index=${i++}, __name__="${constr.name}",__enum__=${enumType.name}},'
					+ '{__tostring=function(self)return"${enumType.name}.${constr.name}"end})\n';
			else
			{
				var aI:Int = 0;
				var args:Array<String> = constr.args.map((f) -> '[${++aI}]=' + constr.args[aI - 1].name);
				output += '${enumType.name}.${constr.name} = function(${constr.args.map((f) -> f.name).join(",")})'
					+ 'return setmetatable('
					+ '{_index=${i++},${args.join(",")}, __name__="${constr.name}",__enum__=${enumType.name}},'
					+ '{__tostring=function(self)return"${enumType.name}.${constr.name}"end})end\n';
			}
		}

		output += 'setmetatable(${enumType.name}, {\n\t__tostring = function(self)\n\t\treturn "Enum<${enumType.name}>"\n\tend\n})\n';

		/*
			output += 'local ${enumType.name}\n${enumType.name} = setmetatable({\n';

			var i = 0;
			for (constr in constructs)
			{
				if (constr.args.length == 0)
					output += '\t${constr.name} = setmetatable('
						+ '{_index=${i++}, __name__="${constr.name}",__enum__=${enumType.name}},'
						+ '{__tostring=function(self)return"${enumType.name}.${constr.name}"end}),\n';
				else
				{
					var aI:Int = 0;
					var args:Array<String> = constr.args.map((f) -> '[${++aI}]=' + constr.args[aI - 1].name);
					output += '\t${constr.name} = function(${constr.args.map((f) -> f.name).join(",")})'
						+ 'return setmetatable('
						+ '{_index=${i++},${args.join(",")}, __name__="${constr.name}",__enum__=${enumType.name}},'
						+ '{__tostring=function(self)return"${enumType.name}.${constr.name}"end})end,\n';
				}
		}*/

		output += '${enumType.name}.__index = ${enumType.name}\n';
		output += '${enumType.name}.__name__ = "${enumType.name}"\n';
		output += '${enumType.name}.__fenum__ = {${constructs.map((f) -> '"${f.name}"').join(", ")}}\n';

		var emptyConstr = constructs.filter((f) -> f.args.length == 0);
		var paramConstr = constructs.filter((f) -> f.args.length > 0);
		if (emptyConstr.length > 0)
			output += '${enumType.name}.__empty_constr__ = {${emptyConstr.map((f) -> f.name).map((n) -> '${enumType.name}.$n').join(", ")}}\n';
		if (paramConstr.length > 0)
		{
			output += '${enumType.name}.__param_constr__ = {';
			var i = paramConstr.length - 1;
			for (c in paramConstr)
			{
				output += '["${c.name}"]={${c.args.map((f) -> '"${f.name}"').join(",")}}';
				if (i-- > 0)
					output += ', ';
			}
			output += '}\n';
		}

		output += "\n";

		return output;
	}
}
#end
