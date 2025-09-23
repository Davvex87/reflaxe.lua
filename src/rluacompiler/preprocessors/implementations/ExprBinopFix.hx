package rluacompiler.preprocessors.implementations;

import haxe.macro.Context;
#if (macro || rlua_runtime)
import reflaxe.BaseCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.preprocessors.BasePreprocessor;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypedExprTools;

using StringTools;

class ExprBinopFix extends BasePreprocessor
{
	public function new() {}

	public function process(data:ClassFuncData, compiler:BaseCompiler)
	{
		data.setExpr(processExpr(data.expr));
	}

	public function processExpr(expr:TypedExpr):TypedExpr
	{
		switch (expr.expr)
		{
			case TBinop(op, e1, e2):
				switch (op)
				{
					case OpAssign:
						if (e1.expr.match(TConst(TNull)))
						{
							return {
								expr: TVar({
									id: Std.random(100000),
									name: "i",
									t: e1.t,
									capture: false,
									meta: null,
									extra: null,
									isStatic: false
								}, e2),
								pos: expr.pos,
								t: expr.t
							}
						}
					default:
				}
				return expr;

			default:
				return TypedExprTools.map(expr, processExpr);
		}
	}
}
#end
