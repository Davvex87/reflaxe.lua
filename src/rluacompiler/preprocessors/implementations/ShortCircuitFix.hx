package rluacompiler.preprocessors.implementations;

#if (macro || rlua_runtime)
import reflaxe.BaseCompiler;
import reflaxe.data.ClassFieldData;
import reflaxe.preprocessors.BasePreprocessor;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypedExprTools;

/**
	Preserves short-circuit semantics of `&&` and `||`.

	The EverythingIsExprSanitizer hoists block-like sub-expressions (inlined
	getters, ternaries, switches, `i++`, ...) into temporary variables placed
	BEFORE the statement they belong to. When such an expression sits on the
	right-hand side of `&&`/`||`, it ends up being evaluated unconditionally:

		if (x.nodeType == Element && x.nodeName == name) ...
	became
		local tmp = x.nodeName -- throws if x is not an Element
		if (x.nodeType == Element and tmp == name) ...

	This preprocessor must run BEFORE the sanitizer. It rewrites
		a && b  =>  if (a) b else false
		a || b  =>  if (a) true else b
	whenever `b` would need hoisting, so the hoisted statements end up inside
	the conditional branch.
**/
class ShortCircuitFix extends BasePreprocessor
{
	public function new() {}

	public function process(data:ClassFieldData, compiler:BaseCompiler)
	{
		data.setExpr(processExpr(data.expr));
	}

	public function processExpr(expr:TypedExpr):TypedExpr
	{
		expr = TypedExprTools.map(expr, processExpr);

		switch (expr.expr)
		{
			case TBinop(op = (OpBoolAnd | OpBoolOr), e1, e2) if (needsHoisting(e2)):
				final boolConst:TypedExpr = {
					expr: TConst(TBool(op == OpBoolOr)),
					pos: expr.pos,
					t: expr.t
				};
				final eif = op == OpBoolAnd ? e2 : boolConst;
				final eelse = op == OpBoolAnd ? boolConst : e2;
				return {
					expr: TIf(e1, eif, eelse),
					pos: expr.pos,
					t: expr.t
				};

			default:
		}
		return expr;
	}

	static function needsHoisting(expr:TypedExpr):Bool
	{
		var found = false;
		function check(e:TypedExpr)
		{
			if (found)
				return;
			switch (e.expr)
			{
				case TFunction(_):
					// functions get their own scope so nothing should leak out
				case TBlock([single]):
					check(single);
				case TBlock(_) | TIf(_, _, _) | TSwitch(_, _, _) | TTry(_, _) | TVar(_, _):
					found = true;
				case TBinop(OpAssign | OpAssignOp(_), _, _):
					found = true;
				case TUnop(OpIncrement | OpDecrement, _, _):
					found = true;
				default:
					TypedExprTools.iter(e, check);
			}
		}
		check(expr);
		return found;
	}
}
#end
