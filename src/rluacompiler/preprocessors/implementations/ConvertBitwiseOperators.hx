package rluacompiler.preprocessors.implementations;

#if (macro || rlua_runtime)
import reflaxe.BaseCompiler;
import reflaxe.data.ClassFieldData;
import reflaxe.preprocessors.BasePreprocessor;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypedExprTools;
import haxe.macro.Context;
import rluacompiler.utils.LuaVUtils;
import reflaxe.helpers.TypedExprHelper.make;

using reflaxe.helpers.TypedExprHelper;
using reflaxe.helpers.RefHelper;
using reflaxe.helpers.NullHelper;

class ConvertBitwiseOperators extends BasePreprocessor
{
	var bitClassPackage:String;
	var options:BitwiseOperatorsProxyOptions;
	var bitClassRef:Null<Ref<ClassType>> = null;

	public function new(bitClassPackage:String, options:BitwiseOperatorsProxyOptions)
	{
		this.bitClassPackage = bitClassPackage;
		this.options = options;

		Context.onAfterInitMacros(() ->
		{
			for (mod in Context.getModule(bitClassPackage))
			{
				switch (mod)
				{
					case TInst(c, _):
						bitClassRef = c;
					case _:
				}
			}
		});
	}

	public function process(data:ClassFieldData, compiler:BaseCompiler)
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
		var bitClassTType = TTypeExpr(TClassDecl(bitClassRef.trustMe()));
		function gitFieldRef(n:String)
			return bitClassRef.get().statics.get().filter(f -> f.name == n)[0].buildRef();

		function fcall(e:TypedExprDef, a:Array<TypedExpr>)
			return make(TCall(make(e, expr.t, expr.pos), a), expr.t, expr.pos);

		function makeBitOp(op:Binop, e1:TypedExpr, ?e2:TypedExpr)
		{
			var opFnCall = getOpProxy(op);
			if (opFnCall != null)
			{
				var args = [e1];
				if (e2 != null)
					args.push(e2);

				return fcall(TField({
					expr: bitClassTType,
					pos: expr.pos,
					t: expr.t
				}, FStatic(bitClassRef, gitFieldRef(opFnCall))), args);
			}
			return null;
		}

		switch (expr.expr)
		{
			case TBinop(OpAssignOp(op), e1, e2):
				e1 = processExpr(e1);
				e2 = processExpr(e2);

				var bitCall = makeBitOp(op, e1, e2);
				return {
					expr: bitCall != null ? TBinop(OpAssign, e1, bitCall) : TBinop(OpAssignOp(op), e1, e2),
					pos: expr.pos,
					t: expr.t
				}

			case TBinop(op, e1, e2):
				e1 = processExpr(e1);
				e2 = processExpr(e2);

				return makeBitOp(op, e1, e2) ?? {
					expr: TBinop(op, e1, e2),
					pos: expr.pos,
					t: expr.t
				};

			case TUnop(OpNegBits, postFix, e):
				e = processExpr(e);

				return fcall(TField({
					expr: bitClassTType,
					pos: expr.pos,
					t: expr.t
				}, FStatic(bitClassRef, gitFieldRef(options.opNegBits))), [e]);

			default:
				return TypedExprTools.map(expr, processExpr);
		}
	}
}
#end
