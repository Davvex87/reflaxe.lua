package rluacompiler.preprocessors.implementations;

#if (macro || rlua_runtime)
import reflaxe.BaseCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.preprocessors.BasePreprocessor;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypedExprTools;
import rluacompiler.utils.LuaVUtils;

class ConvertBitwiseOperators extends BasePreprocessor
{
	var inlineMethod:String;
	var options:BitwiseOperatorsProxyOptions;

	public function new(inlineMethod:String, options:BitwiseOperatorsProxyOptions)
	{
		this.inlineMethod = inlineMethod;
		this.options = options;
	}

	public function process(data:ClassFuncData, compiler:BaseCompiler)
	{
		data.setExpr(processExpr(data.expr));
	}

	function getOpProxy(op:Binop):Null<String>
		return switch (op)
		{
			case OpAnd: options.opAnd;
			case OpOr: options.opOr;
			case OpXor: options.opXor;
			case OpShl: options.opShl;
			case OpShr: options.opShr;
			case OpUShr: options.opUShr;
			case _: null;
		}

	public function processExpr(expr:TypedExpr):TypedExpr
	{
		switch (expr.expr)
		{
			case TBinop(op, e1, e2):
				e1 = processExpr(e1);
				e2 = processExpr(e2);

				if (op.match(OpAssignOp(_)))
				{
					var opFnCall = getOpProxy(switch (op)
					{
						case OpAssignOp(op2): op2;
						case _: null;
					});
					if (opFnCall != null)
					{
						return { // TODO: Maybe use as TField instead of a TIdent here?
							expr: TBinop(OpAssign, e1, {
								expr: TCall({
									expr: TIdent(StringTools.replace(inlineMethod, "{op}", opFnCall)),
									pos: expr.pos,
									t: expr.t
								}, [e1, e2]),
								pos: expr.pos,
								t: expr.t
							}),
							pos: expr.pos,
							t: expr.t
						}
					}
					return expr;
				}

				var opFnCall = getOpProxy(op);
				if (opFnCall != null)
				{
					return { // TODO: Maybe use as TField instead of a TIdent here?
						expr: TCall({
							expr: TIdent(StringTools.replace(inlineMethod, "{op}", opFnCall)),
							pos: expr.pos,
							t: expr.t
						}, [e1, e2]),
						pos: expr.pos,
						t: expr.t
					}
				}
				return expr;

			case TUnop(op, postFix, e):
				e = processExpr(e);
				if (op.match(OpNegBits))
					return { // TODO: Maybe use as TField instead of a TIdent here?
						expr: TCall({
							expr: TIdent(StringTools.replace(inlineMethod, "{op}", options.opNegBits)),
							pos: expr.pos,
							t: expr.t
						}, [e]),
						pos: expr.pos,
						t: expr.t
					}

				return expr;

			default:
				return TypedExprTools.map(expr, processExpr);
		}
	}
}
#end
