package rluacompiler.preprocessors.implementations;

#if (macro || rlua_runtime)
import reflaxe.BaseCompiler;
import reflaxe.data.ClassFieldData;
import reflaxe.preprocessors.BasePreprocessor;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.TypedExprTools;

class Lua51LoopContinuePatch extends BasePreprocessor
{
	public function new() {}

	public function process(data:ClassFieldData, compiler:BaseCompiler)
	{
		data.setExpr(processExpr(data.expr));
	}

	public function processExpr(expr:TypedExpr):TypedExpr
	{
		switch (expr.expr)
		{
			case TFor(v, e1, e2):
				return {
					expr: processExprInLoop(expr),
					pos: expr.pos,
					t: expr.t
				};

			case TWhile(econd, e, normalWhile):
				return {
					expr: processExprInLoop(expr),
					pos: expr.pos,
					t: expr.t
				};

			default:
				return TypedExprTools.map(expr, processExpr);
		}
	}

	public function processExprInLoop(expr:TypedExpr):TypedExprDef
	{
		var loopExpression:TypedExpr = switch (expr.expr)
		{
			case TWhile(econd, e, normalWhile):
				e;
			case TFor(v, e1, e2):
				e2;
			case _:
				throw "Expression is not a loop, something must've gone terribly wrong during compilation, please file an issue here: https://github.com/Davvex87/reflaxe.lua/issues/new";
		};

		var hasBreak:Bool = false, hasContinue:Bool = false;
		function exprCheck(expr:TypedExpr)
		{
			switch (expr.expr)
			{
				case TContinue:
					hasContinue = true;
				case TBreak:
					hasBreak = true;
				case TFunction(tfunc):
				default:
					TypedExprTools.iter(expr, exprCheck);
			}
		}

		exprCheck(loopExpression);

		var es:Array<TypedExpr> = [];
		var breakVar:TVar = {
			id: Std.random(100000),
			name: 'loop_break_${Std.random(100000)}',
			t: Context.getType("Bool"),
			capture: false,
			isStatic: false,
			meta: null,
			extra: null
		};

		if (hasBreak && hasContinue)
			es.push({
				expr: TVar(breakVar, {expr: TConst(TBool(false)), pos: expr.pos, t: expr.t}),
				pos: expr.pos,
				t: expr.t
			});

		var blockEx:Array<TypedExpr> = [];
		var loopExpr = {
			expr: TBlock(blockEx),
			pos: expr.pos,
			t: expr.t
		}

		es.push({
			expr: switch (expr.expr)
			{
				case TWhile(econd, e, normalWhile):
					e = repExpr(e, hasContinue ? breakVar : null);
					if (hasContinue)
					{
						blockEx.push({
							expr: TWhile({expr: TConst(TBool(false)), pos: e.pos, t: e.t}, e, false),
							pos: expr.pos,
							t: expr.t
						});
						TWhile(econd, loopExpr, normalWhile);
					}
					else TWhile(econd, e, normalWhile);
				case TFor(v, e1, e2):
					e2 = repExpr(e2, hasContinue ? breakVar : null);
					if (hasContinue)
					{
						blockEx.push({
							expr: TWhile({expr: TConst(TBool(false)), pos: e2.pos, t: e2.t}, e2, false),
							pos: expr.pos,
							t: expr.t
						});
						TFor(v, e1, loopExpr);
					}
					else TFor(v, e1, e2);
				case _:
					throw "Expression is not a loop, something must've gone terribly wrong during compilation, please file an issue here: https://github.com/Davvex87/reflaxe.lua/issues/new";
			},
			pos: expr.pos,
			t: expr.t
		});

		if (hasBreak)
		{
			blockEx.push({
				expr: TIf({
					expr: TBinop(OpEq, {expr: TLocal(breakVar), pos: expr.pos, t: expr.t}, {expr: TConst(TBool(true)), pos: expr.pos, t: expr.t}),
					pos: expr.pos,
					t: expr.t
				}, {
					expr: TBreak,
					pos: expr.pos,
					t: expr.t
				}, null),
				pos: expr.pos,
				t: expr.t
			});
		}

		return TBlock(es);
	}

	function repExpr(expr:TypedExpr, breakVar:Null<TVar>):TypedExpr
	{
		switch (expr.expr)
		{
			case TContinue:
				return {
					expr: TBreak,
					pos: expr.pos,
					t: expr.t
				};

			case TBreak:
				if (breakVar == null)
					return {
						expr: TBreak,
						pos: expr.pos,
						t: expr.t
					};

				return {
					expr: TBlock([
						{
							expr: TBinop(OpAssign, {
								expr: TLocal(breakVar),
								pos: expr.pos,
								t: expr.t
							}, {
								expr: TConst(TBool(true)),
								pos: expr.pos,
								t: expr.t
							}),
							pos: expr.pos,
							t: expr.t
						},
						{
							expr: TBreak,
							pos: expr.pos,
							t: expr.t
						}
					]),
					pos: expr.pos,
					t: expr.t
				};

			default:
				return TypedExprTools.map(expr, (f:TypedExpr) -> repExpr(f, breakVar));
		}
	}
}
#end
