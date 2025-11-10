package rluacompiler.utils;

import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import haxe.macro.Type;

class ModuleUtils
{
	public static function isFullExternImpl(classType:ClassType, varFields:Array<ClassVarData>, funcFields:Array<ClassFuncData>):Bool
	{
		if (!classType.isExtern && !classType.meta.has("native"))
			return false;

		for (varf in varFields)
		{
			var e = varf.field.expr();
			if (e != null)
				return false;
		}

		for (funcf in funcFields)
		{
			if (funcf.expr != null)
				return false;
		}

		return true;
	}
}
