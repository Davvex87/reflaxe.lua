package rluacompiler.subcompilers;

#if (macro || rlua_runtime)
import haxe.macro.Type.BaseType;
import reflaxe.output.StringOrBytes;

using StringTools;

class Modules extends SubCompiler
{
	public function compileImports(curMod:String, usedTypes:Map<String, Array<BaseType>>, files:Map<String, Array<StringOrBytes>>,
			typesPerModule:Map<String, Array<BaseType>>):String
	{
		var output = "";

		for (m => tar in usedTypes)
		{
			if (curMod == m)
				continue;
			if (!files.exists(m))
				continue;
			var ts = typesPerModule.get(m);
			if (ts == null || ts.length == 0)
				continue;
			output += 'local ${ts.map(t -> t.name).join(", ")} = unpack(require("${m}"))\n';
		}

		return output;
	}
}
#end
