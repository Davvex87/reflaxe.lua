package rluacompiler.subcompilers;

#if (macro || rlua_runtime)
import haxe.macro.Type.BaseType;

using StringTools;

class Modules extends SubCompiler
{
	public function compileImports(curMod:String, usedTypes:Map<String, Array<BaseType>>):String
	{
		var output = "";

		for (m => tar in usedTypes)
		{
			if (curMod == m)
				continue;
			output += 'local ${tar.map(t -> t.name).join(", ")} = unpack(require("${m}"))\n';
		}

		return output;
	}
}
#end
