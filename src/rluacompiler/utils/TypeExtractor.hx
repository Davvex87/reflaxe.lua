package rluacompiler.utils;

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
						case FStatic(c, _) | FInstance(c, _, _):
							var cls = c.get();
							if ((!cls.isExtern && !cls.meta.has(":native"))
								|| cls.meta.has(":customImport")) usedTypes.push(cls); else TypedExprTools.iter(e, iter);
						case FEnum(e, ef):
							usedTypes.push(e.get());
						default:
							TypedExprTools.iter(e, iter);
					}
				case TTypeExpr(m):
					switch (m)
					{
						case TClassDecl(c):
							usedTypes.push(c.get());
						case TEnumDecl(e):
							usedTypes.push(e.get());
						default:
							TypedExprTools.iter(e, iter);
					}
				case TNew(c, params, el):
					usedTypes.push(c.get());
					TypedExprTools.iter(e, iter);
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
