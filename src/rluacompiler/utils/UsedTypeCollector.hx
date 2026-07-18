package rluacompiler.utils;

#if (macro || rlua_runtime)
import haxe.macro.Type;
import haxe.macro.TypedExprTools;

using reflaxe.helpers.BaseTypeHelper;

class UsedTypeCollector
{
	public var types:Map<String, BaseType> = new Map<String, BaseType>();

	public function new() {}

	public static function extract(expr:TypedExpr):UsedTypeCollector
	{
		var collector = new UsedTypeCollector();
		collector.collect(expr);
		return collector;
	}

	function shouldInclude(bt:BaseType):Bool
	{
		if (bt.meta.has(":customImport"))
			return true;
		if (bt.isExtern || bt.meta.has(":native"))
			return false;
		return true;
	}

	function add(bt:BaseType):Void
	{
		if (!shouldInclude(bt))
			return;
		types.set(bt.uniqueName(), bt);
	}

	function collectTypesFromType(t:haxe.macro.Type):Void
	{
		switch (t)
		{
			case TInst(c, params):
				add(c.get());
				for (p in params)
					collectTypesFromType(p);
			case TEnum(e, params):
				add(e.get());
				for (p in params)
					collectTypesFromType(p);
			case TAbstract(a, params):
				add(a.get());
				for (p in params)
					collectTypesFromType(p);
			case TType(td, params):
				add(td.get());
				for (p in params)
					collectTypesFromType(p);
			case TFun(args, ret):
				collectTypesFromType(ret);
				for (a in args)
					collectTypesFromType(a.t);
			case TMono(_):
			case TDynamic(_):
			case TAnonymous(_):
			case TLazy(_):
		}
	}

	function iter(e:TypedExpr):Void
	{
		switch e.expr
		{
			case TField(e, fa):
				switch fa
				{
					case FStatic(c, _) | FInstance(c, _, _):
						add(c.get());
						TypedExprTools.iter(e, iter);
					case FEnum(en, _):
						add(en.get());
					default:
						TypedExprTools.iter(e, iter);
				}
			case TTypeExpr(m):
				switch m
				{
					case TClassDecl(c):
						add(c.get());
					case TEnumDecl(e):
						add(e.get());
					case TTypeDecl(t):
						add(t.get());
					case TAbstract(a):
						add(a.get());
				}
			case TNew(c, params, args):
				add(c.get());
				for (p in params)
					collectTypesFromType(p);
				TypedExprTools.iter(e, iter);
			case TFunction(tfunc):
				collectTypesFromType(tfunc.t);
				for (arg in tfunc.args)
					collectTypesFromType(arg.v.t);
				TypedExprTools.iter(tfunc.expr, iter);
			case TVar(tv, expr):
				collectTypesFromType(tv.t);
				if (expr != null)
					TypedExprTools.iter(expr, iter);
			default:
				TypedExprTools.iter(e, iter);
		}
	}

	public function collect(expr:TypedExpr):Void
	{
		TypedExprTools.iter(expr, iter);
	}

	public function getTypes():Array<BaseType>
	{
		return [for (bt in types.iterator()) bt];
	}

	public function getTypesByModule():Map<String, Array<BaseType>>
	{
		var result = new Map<String, Array<BaseType>>();
		for (bt in types)
		{
			var mod = bt.module;
			if (!result.exists(mod))
				result.set(mod, []);
			result.get(mod).push(bt);
		}
		return result;
	}
}
#end
