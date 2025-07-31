package rluacompiler.preprocessors.implementations;

#if (macro || rlua_runtime)
import haxe.macro.Type.TypedExpr;
import haxe.macro.Type.TypedExprDef;
import reflaxe.BaseCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.preprocessors.BasePreprocessor;
import haxe.macro.Expr;
import haxe.macro.Type;

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
		return switch(op)
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
		switch(expr.expr)
		{
			case TBinop(op, e1, e2): //TODO: Maybe use as TField instead of a TIdent here?
				e1 = processExpr(e1);
				e2 = processExpr(e2);

				if (op.match(OpAssignOp(_)))
				{
					var opFnCall = getOpProxy(switch(op) {case OpAssignOp(op2): op2; case _: null;});
					if (opFnCall != null)
					{
						expr.expr = TBinop(OpAssign, e1, {
							expr: TCall({
								expr: TIdent(StringTools.replace(inlineMethod, "{op}", opFnCall)),
								pos: expr.pos,
								t: expr.t
							}, [e1, e2]),
							pos: expr.pos,
							t: expr.t
						});
					}
					return expr;
				}

				var opFnCall = getOpProxy(op);
				if (opFnCall != null)
				{
					expr.expr = TCall({
						expr: TIdent(StringTools.replace(inlineMethod, "{op}", opFnCall)),
						pos: expr.pos,
						t: expr.t
					}, [e1, e2]);
				}

			case TUnop(op, postFix, e):
				e = processExpr(e);
				if (op.match(OpNegBits))
					expr.expr = TCall({ //TODO: Maybe use as TField instead of a TIdent here?
						expr: TIdent(StringTools.replace(inlineMethod, "{op}", options.opNegBits)),
						pos: expr.pos,
						t: expr.t
					}, [e]);

			case TBlock(el):
				for (e in el)
					e = processExpr(e);

			case TArray(e1, e2):
				e1 = processExpr(e1);
				e2 = processExpr(e2);

			case TParenthesis(e):
				e = processExpr(e);

			case TObjectDecl(fields):
				for (f in fields)
					f.expr = processExpr(f.expr);

			case TArrayDecl(el):
				for (e in el)
					e = processExpr(e);

			case TCall(e, el):
				for (e in el)
					e = processExpr(e);

			case TNew(c, params, el):
				for (e in el)
					e = processExpr(e);

			case TVar(v, expr):
				if (expr != null) expr = processExpr(expr);

			case TFor(v, e1, e2):
				e1 = processExpr(e1);
				e2 = processExpr(e2);

			case TIf(econd, eif, eelse):
				econd = processExpr(econd);
				eif = processExpr(eif);
				if (eelse != null) eelse = processExpr(eelse);

			case TWhile(econd, e, normalWhile):
				econd = processExpr(econd);
				e = processExpr(e);

			case TSwitch(e, cases, edef):
				e = processExpr(e);
				for (c in cases) c.expr = processExpr(c.expr);
				if (edef != null) edef = processExpr(edef);

			case TTry(e, catches):
				e = processExpr(e);
				for (c in catches) c.expr = processExpr(c.expr);

			case TReturn(e):
				if (e != null) e = processExpr(e);

			case TThrow(e):
				e = processExpr(e);

			case TCast(e, m):
				e = processExpr(e);

			case TEnumParameter(e1, ef, index):
				e1 = processExpr(e1);

			case TEnumIndex(e1):
				e1 = processExpr(e1);

			case _:
		}
		return expr;
	}
}

@:structInit
class BitwiseOperatorsProxyOptions
{
	/**
		`&`
	**/
	public var opAnd:String;

	/**
		`|`
	**/
	public var opOr:String;

	/**
		`^`
	**/
	public var opXor:String;

	/**
		`<<`
	**/
	public var opShl:String;

	/**
		`>>`
	**/
	public var opShr:String;

	/**
		`>>>`
	**/
	public var opUShr:String;

	/**
		`~`
	**/
	public var opNegBits:String;
}
#end
