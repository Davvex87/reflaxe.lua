package rluacompiler.preprocessors.implementations;

#if (macro || rlua_runtime)
import reflaxe.BaseCompiler;
import reflaxe.data.ClassFieldData;
import reflaxe.preprocessors.BasePreprocessor;
import haxe.macro.Expr;
import haxe.macro.Type;
import reflaxe.helpers.NullHelper;
import haxe.macro.Context;
import haxe.macro.TypedExprTools;

class LuaMultiReturnPatch extends BasePreprocessor
{
	public function new() {}

	var compiler:BaseCompiler;

	public function process(data:ClassFieldData, compiler:BaseCompiler)
	{
		this.compiler = compiler;
		data.setExpr(processExpr(data.expr));
	}

	public function processExpr(expr:TypedExpr):TypedExpr
	{
		switch (expr.expr)
		{
			case TCall(e, el):
				var t = getFieldType(e);
				var multiReturnType:Null<Ref<ClassType>> = null;
				switch (t)
				{
					case TFun(args, ret):
						switch (ret)
						{
							case TInst(t, params):
								multiReturnType = t;
							case _:
						}

					case _:
				}

			if (multiReturnType == null || !NullHelper.trustMe(multiReturnType).get().meta.has(":multiReturn"))
				return TypedExprTools.map(expr, processExpr);

			var runtimeClassRef:Null<Ref<ClassType>> = null;
			for(mod in Context.getModule("rlua.Runtime")) {
				switch(mod) {
					case TInst(c, _): runtimeClassRef = c;
					case _:
				}
			}

			var runtimeClassRefVal = NullHelper.trustMe(runtimeClassRef);

			var buildMultiReturnField = cast {
				get: () -> ({
					name: "BuildMultiReturn",
					type: TFun([{ name: "n", opt: false, t: TDynamic(null) }], TDynamic(null)),
					pos: expr.pos,
					meta: {
						has: function(_) return false,
						get: function() return [],
						extract: function(_) return [],
						add: function(_, _, _) {},
						remove: function(_) return false,
					},
					kind: FMethod(MethNormal),
					params: [],
					overloads: null,
					expr: function():Null<TypedExpr> return null,
					doc: null,
					isPublic: true,
					isExtern: true,
					isFinal: false,
					isAbstract: false,
				}: ClassField),
				toString: () -> "BuildMultiReturn",
			};

			return {
				expr: TCall({
					expr: TField({
						expr: TTypeExpr(TClassDecl(runtimeClassRefVal)),
						pos: expr.pos,
						t: expr.t
					}, FStatic(runtimeClassRefVal, buildMultiReturnField)),
					pos: expr.pos,
					t: expr.t
				}, [
					{
						expr: TArrayDecl(NullHelper.trustMe(multiReturnType).get().fields.get().map((f) -> {
							expr: TConst(TString(f.name)),
							pos: expr.pos,
							t: expr.t
						})),
						pos: expr.pos,
						t: expr.t
					},
					{
						expr: TCall(e, el),
						pos: expr.pos,
						t: expr.t
					}
				]),
				pos: expr.pos,
				t: expr.t
			};

			default:
				return TypedExprTools.map(expr, processExpr);
		}
	}

	public function getFieldType(expr:TypedExpr):Null<Type>
	{
		return switch (expr.expr)
		{
			case TLocal(v):
				v.t;

			case TArray(e1, e2):
				getFieldType(e1);

			case TBinop(op, e1, e2):
				getFieldType(e1);

			case TField(e, fa):
				switch (fa)
				{
					case FInstance(c, params, cf):
						cf.get().type;

					case FStatic(c, cf):
						cf.get().type;

					case FAnon(cf):
						cf.get().type;

					case FDynamic(s):
						null;

					case FClosure(c, cf):
						cf.get().type;

					case FEnum(e, ef):
						ef.type;
				}

			case TParenthesis(e):
				getFieldType(e);

			case TObjectDecl(fields):
				null;

			case TCall(e, el):
				getFieldType(e);

			case TUnop(op, postFix, e):
				getFieldType(e);

			case TFunction(tfunc):
				tfunc.t;

			case TVar(v, expr):
				v.t;

			case TBlock(el):
				for (r in el)
				{
					switch (getReturnExpr(r).expr)
					{
						case TReturn(e):
							if (e == null)
								return null;
							getFieldType(e);
						case _:
					}
				}
				return null;

			case TCast(e, m):
				if (m != null)
					getFieldType({
						expr: TTypeExpr(m),
						pos: expr.pos,
						t: expr.t
					});
				null;

			case TEnumParameter(e1, ef, index):
				getFieldType(e1);

			case TEnumIndex(e1):
				getFieldType(e1);

			default:
				null;
		}
	}

	private var _lastRetExpr:Null<TypedExpr> = null;

	public function getReturnExpr(expr:TypedExpr):TypedExpr
	{
		_lastRetExpr = null;
		TypedExprTools.iter(expr, _iterExpr);
		return _lastRetExpr;
	}

	private function _iterExpr(expr:TypedExpr):Void
	{
		switch (expr.expr)
		{
			case TReturn(e):
				_lastRetExpr = expr;
			case TFunction(tfunc):
			default:
				TypedExprTools.iter(expr, getReturnExpr);
		}
	}
}
#end
