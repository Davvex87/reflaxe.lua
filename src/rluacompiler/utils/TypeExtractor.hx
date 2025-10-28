package rluacompiler.utils;

import rlua.Lua.print;
#if (macro || rlua_runtime)
import haxe.macro.TypedExprTools;
import haxe.macro.Type;

using reflaxe.helpers.BaseTypeHelper;

class TypeExtractor
{
	public static function extractAllUsedTypes(expr:TypedExpr):Array<BaseType>
	{
		var usedTypes = new Array<BaseType>();
		function iter(e:TypedExpr)
		{
			switch (e.expr)
			{
				case TField(e, fa):
					switch (fa)
					{
						// case FInstance(c, params, cf):
						case FStatic(c, cf):
							usedTypes.push(c.get());
						// case FAnon(cf):
						// case FDynamic(s):
						// case FClosure(c, cf):
						case FEnum(e, ef):
							usedTypes.push(e.get());
						default:
					}
				case TTypeExpr(m):
					switch (m)
					{
						case TClassDecl(c):
							usedTypes.push(c.get());
						case TEnumDecl(e):
							usedTypes.push(e.get());
						// case TTypeDecl(t):
						// case TAbstract(a):
						default:
					}
				case TNew(c, params, el):
					usedTypes.push(c.get());
				default:
					TypedExprTools.iter(e, iter);
			}
		}

		TypedExprTools.iter(expr, iter);

		var fixedTypes = new Array<BaseType>();
		for (t in usedTypes)
		{
			var exists = false;
			for (ft in fixedTypes)
			{
				if (ft.equals(t))
				{
					exists = true;
					break;
				}
			}
			if (!exists)
				fixedTypes.push(t);
		}

		return fixedTypes;
	}
}
#end
