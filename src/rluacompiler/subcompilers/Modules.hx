package rluacompiler.subcompilers;

#if (macro || rlua_runtime)
import haxe.macro.Type.BaseType;
import reflaxe.output.StringOrBytes;
import rluacompiler.resources.IPkgWrapper;

using StringTools;

class Modules extends SubCompiler
{
	public function compileImports(curMod:String, usedTypes:Map<String, Array<BaseType>>, files:Map<String, Array<StringOrBytes>>,
			typesPerModule:Map<String, Array<BaseType>>, pkgWrapperClass:Null<IPkgWrapper>):String
	{
		var output = "";
		var importFunctionCode = pkgWrapperClass != null ? 'importPkg("%")' : 'require("%")';

		for (m => tar in usedTypes)
		{
			if (curMod == m)
				continue;
			if (!files.exists(m))
				continue;
			var ts = typesPerModule.get(m);
			if (ts == null || ts.length == 0)
				continue;
			output += 'local ${ts.map(t -> {
				if (t.meta.has(":customImport"))
					return "_";
				return t.name;
			}).join(", ")}';
			output += {
				if (pkgWrapperClass != null)
					' = ${pkgWrapperClass.importCode(m)}\n';
				else
					' = require("$m")\n';
			};
		}

		return output;
	}
}
#end
