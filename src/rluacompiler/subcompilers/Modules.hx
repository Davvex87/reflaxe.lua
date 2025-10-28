package rluacompiler.subcompilers;

#if (macro || rlua_runtime)
import haxe.macro.Type.BaseType;
import reflaxe.output.StringOrBytes;

using StringTools;

class Modules extends SubCompiler
{
	public function compileImports(curMod:String, usedTypes:Map<String, Array<BaseType>>, files:Map<String, Array<StringOrBytes>>):String
	{
		var output = "";

		for (m => tar in usedTypes)
		{
			if (curMod == m)
				continue;
			if (!files.exists(m))
				continue;
			output += 'local ${tar.map(t -> t.name).join(", ")} = unpack(require("${m}"))\n';
		}

		return output;
	}
}
#end
