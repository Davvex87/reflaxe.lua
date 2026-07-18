package rluacompiler.preprocessors.implementations;

#if (macro || rlua_runtime)
import reflaxe.BaseCompiler;
import reflaxe.data.ClassFieldData;
import reflaxe.preprocessors.BasePreprocessor;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypedExprTools;
import haxe.macro.Context;

using StringTools;
using rluacompiler.utils.ModuleUtils;
using reflaxe.helpers.TypedExprHelper;

class IteratorFix extends BasePreprocessor
{
	var compiler:Compiler;

	var implClassCache:Null<Map<String, ImplEntry>>;

	var configs:Array<AbstractRedirectConfig>;

	public function new(configs:Array<AbstractRedirectConfig>)
	{
		this.configs = configs;
	}

	public function process(data:ClassFieldData, compiler:BaseCompiler)
	{
		this.compiler = cast compiler;
		if (implClassCache == null)
		{
			implClassCache = new Map();
			findImplClasses();
		}
		data.setExpr(processExpr(data.expr));
	}

	function findImplClasses():Void
	{
		for (config in configs)
		{
			try
			{
				var t = Context.getType(config.abstractModule);
				switch (t)
				{
					case TAbstract(absRef, _):
						var abs = absRef.get();
						if (abs.impl == null) continue;

						var implClass = abs.impl.get();

						var interfaceModules = config.interfaceModules;
						if (interfaceModules == null)
						{
							interfaceModules = detectInterfaceModules(abs);
						}

						if (interfaceModules == null) continue;

						var implName = implClass.extractName();

						for (ifaceModule in interfaceModules)
						{
							if (!implClassCache.exists(ifaceModule))
							{
								implClassCache.set(ifaceModule, {
									implClass: implClass,
									implName: implName
								});
							}
						}

					default:
				}
			}
			catch (e:Dynamic) {}
		}
	}

	function detectInterfaceModules(abs:AbstractType):Null<Array<String>>
	{
		if (abs.type == null) return null;

		var modules:Array<String> = [];

		switch (abs.type)
		{
			case TInst(t, _):
				var cls = t.get();
				collectInterfaceModules(cls, modules);
				return modules;

			case TAbstract(a, _):
				return detectInterfaceModules(a.get());

			default:
		}

		return modules.length > 0 ? modules : null;
	}

	function collectInterfaceModules(cls:ClassType, modules:Array<String>):Void
	{
		if (cls.isInterface && !modules.contains(cls.module))
		{
			modules.push(cls.module);
		}
		for (iface in cls.interfaces)
		{
			var ifaceCls = iface.t.get();
			if (!modules.contains(ifaceCls.module))
			{
				modules.push(ifaceCls.module);
			}
			collectInterfaceModules(ifaceCls, modules);
		}
	}

	public function processExpr(expr:TypedExpr):TypedExpr
	{
		switch (expr.expr)
		{
			case TCall(e, args):
				switch (e.expr)
				{
					case TField(obj, fa):
						var methodName = getFieldName(fa);
						if (methodName == null) return TypedExprTools.map(expr, processExpr);

						var cls = getFieldClass(fa);
						if (cls != null && cls.isInterface)
						{
							var replacement = tryRedirectToImpl(cls, methodName, obj, args, expr.t, expr.pos);
							if (replacement != null) return replacement;
						}

						return TypedExprTools.map(expr, processExpr);

					default:
						return TypedExprTools.map(expr, processExpr);
				}

			default:
				return TypedExprTools.map(expr, processExpr);
		}
	}

	function tryRedirectToImpl(cls:ClassType, methodName:String, obj:TypedExpr, args:Array<TypedExpr>, resultType:Type, pos:Position):Null<TypedExpr>
	{
		for (ifaceModule => entry in implClassCache)
		{
			if (isOrImplements(cls, ifaceModule))
			{
				return buildRedirectCall(entry, methodName, obj, args, resultType, pos);
			}
		}
		return null;
	}

	function isOrImplements(cls:ClassType, targetInterfaceModule:String):Bool
	{
		if (cls.module == targetInterfaceModule) return true;
		for (iface in cls.interfaces)
		{
			if (iface.t.get().module == targetInterfaceModule) return true;
			if (isOrImplements(iface.t.get(), targetInterfaceModule)) return true;
		}
		return false;
	}

	function buildRedirectCall(entry:ImplEntry, methodName:String, obj:TypedExpr, args:Array<TypedExpr>, resultType:Type, pos:Position):Null<TypedExpr>
	{
		switch (methodName)
		{
			case "get":
				return {
					expr: TArray(obj, args[0]),
					pos: pos,
					t: resultType
				};

			case "set":
				return {
					expr: TBinop(OpAssign, {expr: TArray(obj, args[0]), pos: pos, t: args[1].t}, args[1]),
					pos: pos,
					t: resultType
				};

			default:
				return buildStaticCall(entry, methodName, obj, args, resultType, pos);
		}
	}

	function buildStaticCall(entry:ImplEntry, methodName:String, obj:TypedExpr, args:Array<TypedExpr>, resultType:Type, pos:Position):TypedExpr
	{
		var templateBuf = new StringBuf();
		templateBuf.add(entry.implName);
		templateBuf.add(".");
		templateBuf.add(methodName);
		templateBuf.add("({0}");
		for (i in 0...args.length)
		{
			templateBuf.add(", {");
			templateBuf.add(Std.string(i + 1));
			templateBuf.add("}");
		}
		templateBuf.add(")");

		return makeLuaCall(templateBuf.toString(), [obj].concat(args), pos, resultType);
	}

	function makeLuaCall(template:String, args:Array<TypedExpr>, pos:Position, resultType:Type):TypedExpr
	{
		var luaIdent:TypedExpr = {
			expr: TIdent("__lua__"),
			pos: pos,
			t: Context.getType("String")
		};

		var templateExpr:TypedExpr = {
			expr: TConst(TString(template)),
			pos: pos,
			t: Context.getType("String")
		};

		return {
			expr: TCall(luaIdent, [templateExpr].concat(args)),
			pos: pos,
			t: resultType
		};
	}

	function getFieldName(fa:FieldAccess):Null<String>
	{
		return switch (fa)
		{
			case FInstance(c, params, cf): cf.get().name;
			case FStatic(c, cf): cf.get().name;
			case FAnon(cf): cf.get().name;
			case FClosure(c, cf): cf.get().name;
			case FDynamic(s): s;
			case FEnum(en, ef): ef.name;
		}
	}

	function getFieldClass(fa:FieldAccess):Null<ClassType>
	{
		return switch (fa)
		{
			case FInstance(c, params, cf): c.get();
			case FStatic(c, cf): c.get();
			default: null;
		}
	}
}

typedef AbstractRedirectConfig = {
	var abstractModule:String;
	@:optional var interfaceModules:Array<String>;
}

typedef ImplEntry = {
	var implClass:ClassType;
	var implName:String;
}
#end
