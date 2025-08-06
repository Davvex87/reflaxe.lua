package rluacompiler.subcompilers;

#if (macro || rlua_runtime)

import reflaxe.DirectToStringCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;
import reflaxe.ReflectCompiler;
import haxe.macro.Expr;
import rluacompiler.utils.CodeBuf;
import haxe.macro.Type;
import haxe.macro.TypedExprTools;

using StringTools;

class Expressions extends SubCompiler
{
	public function compileExpressionImpl(expr: TypedExpr, depth: Int, ?previous:TypedExpr): Null<String>
	{
		function exprImpl(e:TypedExpr, depthOffset:Int = 0): Null<String>
			return compileExpressionImpl(e, depth + depthOffset, expr);

		return switch(expr.expr)
		{
			case TConst(c):
				switch(c)
				{
					case TInt(i):
						Std.string(i);

					case TFloat(s):
						Std.string(s);

					case TString(s):
						s = StringTools.replace(s, "\\", "\\\\");
						s = StringTools.replace(s, "\"", "\\\"");
						s = StringTools.replace(s, "\t", "\\t");
						s = StringTools.replace(s, "\n", "\\n");
						s = StringTools.replace(s, "\r", "\\r");
						'"$s"';

					case TBool(b):
						Std.string(b);

					case TNull:
						"nil";

					case TThis:
						"self";

					case TSuper:
						"self.__super__";

					default:
						null;
				}

			case TLocal(v):
				v.name;

			case TArray(e1, e2):
				var num = switch(e2.expr)
				{
					case TConst(c):
						switch(c)
						{
							case TInt(i):
								i;
							case _:
								null;
						}
					case _:
						null;
				}
				if (num != null)
					'${exprImpl(e1)}[${num+1}]';
				else
					'${exprImpl(e1)}[${exprImpl(e2)}+1]';

			case TBinop(op, e1, e2):
				switch(op)
				{
					case OpAssignOp(op):
						'${exprImpl(e1)} = ${exprImpl(e1)} ${compileOperatorImpl(op, e1, e2)} ${exprImpl(e2)}';
					default:
						'${exprImpl(e1)} ${compileOperatorImpl(op, e1, e2)} ${exprImpl(e2)}';
				}

			case TField(e, fa):
				switch(fa)
				{
					case FInstance(c, params, cf):
						var field = cf.get();
						var accessor = switch(field.kind)
						{
							case FMethod(_) if (!e.expr.match(TConst(TSuper))): ":";
							case FVar(_, _): ".";
							default: ".";
						}
						'${exprImpl(e)}${accessor}${field.name}';
					case FStatic(c, cf):
						if (c.get().name.length == 0)
							cf.get().name;
						else
							'${c.get().name}.${cf.get().name}';
					case FAnon(cf):
						'${exprImpl(e)}.${cf.get().name}';
					case FDynamic(s):
						'${exprImpl(e)}.${s}';
					case FClosure(c, cf):
						'${exprImpl(e)}.${cf.get().name}';
					case FEnum(e, ef):
						'${e.get().name}.${ef.name}';
				}

			case TTypeExpr(m):
				switch(m)
				{
					case TClassDecl(c):
						c.get().name;
					case TEnumDecl(e):
						e.get().name;
					case TTypeDecl(t):
						t.get().name;
					case TAbstract(a):
						a.get().name;
				}

			case TParenthesis(e):
				'(${exprImpl(e)})';

			case TObjectDecl(fields):
				var buff:CodeBuf = new CodeBuf();

				var fieldStrs = fields.map(f -> '${f.name} = ${exprImpl(f.expr)}');
				buff += '{${buff.enter}';
				buff += fieldStrs.join(",\n");
				buff += '${buff.leave}}';
				buff;

			case TArrayDecl(el):
				var elements = el.map(e -> exprImpl(e));
				'{${elements.join(", ")}}';

			case TCall(e, el):
				var code = main.compileNativeFunctionCodeMeta(e, el);
				if (code != null)
					return code;
				
				switch(e.expr)
				{
					case TIdent(s):
						switch(s)
						{
							case "__lua__":
								return parseUntypedSyntaxCode(el);
							case _:
						}

					case TField(e, fa):
						switch(fa) {
							case FStatic(c, cf):
								if (c.get().name == "Syntax" && cf.get().name == "code")
									return parseUntypedSyntaxCode(el);
							case _:
						}
					case _:
				};

				var field = exprImpl(e);

				var isSuperCall:Bool = field.startsWith("self.__super__");

				if (field == "self.__super__")
					field += ".__constructor";

				var args = el.map(arg -> exprImpl(arg));
				if (isSuperCall)
					args.insert(0, "self");
				'$field(${args.join(", ")})';

			case TNew(c, params, el):
				var code = main.compileNativeFunctionCodeMeta(expr, el);
				if (code != null)
					return code;

				var args = el.map(arg -> exprImpl(arg));
				'${c.get().name}.new(${args.join(", ")})';

			case TUnop(op, postFix, e):
				switch(op) {
					case OpIncrement:
						var exprStr = exprImpl(e);
						if (postFix) {
							var tempVar = '__temp_${Std.random(100000)}';
							'(function() local ${tempVar} = ${exprStr}; ${exprStr} = ${exprStr} + 1; return ${tempVar} end)()';
						} else 
							'(function() ${exprStr} = ${exprStr} + 1; return ${exprStr} end)()';
						
					case OpDecrement:
						var exprStr = exprImpl(e);
						if (postFix) {
							var tempVar = '__temp_${Std.random(100000)}';
							'(function() local ${tempVar} = ${exprStr}; ${exprStr} = ${exprStr} - 1; return ${tempVar} end)()';
						} else
							'(function() ${exprStr} = ${exprStr} - 1; return ${exprStr} end)()';
						
					case OpNot:
						'not ${exprImpl(e)}';
						
					case OpNeg:
						'-${exprImpl(e)}';
						
					case OpNegBits: // Moved to src/rluacompiler/preprocessors/implementations/ConvertBitwiseOperators.hx
						'~${exprImpl(e)}';
						
					default:
						throw 'Unary operator ${op} not implemented';
				}

			case TFunction(tfunc):
				var args = tfunc.args.map(arg -> arg.v.name);
				var body = exprImpl(tfunc.expr, 1);
				'(function(${args.join(", ")})\n${body}\nend)';

			case TVar(v, expr):
				if (expr != null)
					'local ${v.name} = ${exprImpl(expr)}';
				else
					'local ${v.name}';

			case TBlock(el):
				var alreadyHasBlock = previous != null && switch(previous.expr)
				{
					case TBlock(_): true;
					case TFor(_, _, _): true;
					case TIf(_, _, _): true;
					case TFunction(_): true;
					case TWhile(_, _, _): true;
					case TSwitch(_, _, _): true;
					case TTry(_, _): true;
					default: false;
				}
				
				var statements = el.map(e -> {
					var compiled = exprImpl(e, alreadyHasBlock ? 0 : 1);
					return compiled;
					//return alreadyHasBlock ? compiled : indent(depth + 1) + compiled;
				});
				
				if (statements.length < 1) return "";

				var buff:CodeBuf = new CodeBuf();

				if (depth == 0 || alreadyHasBlock)
					buff += statements.join('\n');
				else
				{
					//buff += 'do\n${statements.join('\n')}\nend';
					buff += 'do${buff.enter}';
					buff += statements.join('\n');
					buff += '${buff.leave}end';
				}

				buff;

			case TFor(v, e1, e2):
				var buff:CodeBuf = new CodeBuf();

				var body = exprImpl(e2, 1);
				//'for ${v.name} in ${exprImpl(e1)} do\n${body}\nend';
				buff += 'for ${v.name} in ${exprImpl(e1)} do${buff.enter}';
				buff += body;
				buff += '${buff.leave}end';
				buff;

			case TIf(econd, eif, eelse):
				var buff:CodeBuf = new CodeBuf();

				buff += 'if ${exprImpl(econd)} then${buff.enter}';
				buff += exprImpl(eif, 1);

				if (eelse != null && !isEmptyBlock(eelse))
				{
					var nextIsIf = eelse.expr.match(TIf(_, _, _));
					buff += '${buff.leave}else';
					if (!nextIsIf)
						buff += '${buff.enter}';
					buff += exprImpl(eelse, 1);
					if (!nextIsIf)
						buff += '${buff.leave}end';
				}
				else
					buff += '${buff.leave}end';

				buff;

			case TWhile(econd, e, normalWhile):
				var buff:CodeBuf = new CodeBuf();

				var body = exprImpl(e, 1);
				if (normalWhile)
				{
					buff += 'while ${exprImpl(econd)} do${buff.enter}';
					buff += body;
					buff += '${buff.leave}end';
				}
				else
				{
					buff += 'repeat${buff.enter}';
					buff += body;
					buff += '${buff.leave}until not (${exprImpl(econd)})';
				}

				buff;

			case TSwitch(e, cases, edef):
				// Lua doesn't have switch, so we'll compile to if-elseif chain
				var buff:CodeBuf = new CodeBuf();

				var switchVar = exprImpl(e);
				var result = "";
				var first = true;
				
				for (c in cases)
				{
					var conditions = c.values.map(v -> '${switchVar} == ${exprImpl(v)}');
					var condStr = conditions.join(' or ');
					var caseBody = exprImpl(c.expr, 1);
					
					if (first)
					{
						buff += 'if ${condStr} then${buff.enter}';
						buff += caseBody;
						first = false;
					}
					else
					{
						buff += '${buff.leave}elseif ${condStr}';
						buff += ' then${buff.enter}';
						buff += caseBody;
					}
				}
				
				if (edef != null && !isEmptyBlock(edef))
				{
					buff += buff.leave;
					buff += 'else${buff.enter}';
					buff += exprImpl(edef, 1);
				}
				
				buff += '${buff.leave}end';
				buff;

			case TTry(e, catches):
				// Lua doesn't have try-catch, we'll use pcall
				var buff:CodeBuf = new CodeBuf();

				var hasReturn = getReturnExpr(e) != null;

				buff += 'local success, result = pcall(function()${buff.enter}';
				buff += exprImpl(e);
				buff += '${buff.leave}end)\n';
				
				if (catches.length > 0)
				{
					buff += 'if not success then${buff.enter}';
					for (c in catches)
					{
						var catchBody = exprImpl(c.expr, 1);
						buff += 'local ${c.v.name} = result\n';
						buff += '${catchBody}';
					}
					if (hasReturn)
					{
						buff += '${buff.leave}else';
						buff += '${buff.enter}return result';
					}
					buff += '${buff.leave}end';
				}
				
				buff;

			case TReturn(e):
				if (e != null)
					'return ${exprImpl(e)}';
				else
					'return';

			case TBreak:
				'break';

			case TContinue:
				'goto continue'; // Lua 5.2+ has goto

			case TThrow(e):
				'error(${exprImpl(e)})';

			case TCast(e, m):
				// In Lua, casting is usually just returning the value
				exprImpl(e);

			case TMeta(m, e1):
				// Metadata is usually ignored in compilation
				exprImpl(e1);

			case TEnumParameter(e1, ef, index):
				'${exprImpl(e1)}[${index + 1}]'; // Lua arrays are 1-indexed

			case TEnumIndex(e1):
				'${exprImpl(e1)}.index';

			case TIdent(s):
				s;

			default:
				null;//throw new NotImplementedException('${expr.expr} has not yet been defined to be compiled');
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
		switch(expr.expr)
		{
			case TReturn(e):
				_lastRetExpr = expr;
			case TFunction(tfunc):
			default:
				TypedExprTools.iter(expr, getReturnExpr);
		}
	}

	public function isEmptyBlock(expr:TypedExpr)
		return switch(expr.expr)
		{
			case TBlock(el):
				el.length == 0;
			case _:
				false;
		}

	public function isStringType(t:Type)
		return switch(t)
		{
			case TMono(t):
				isStringType(t.get());
			case TFun(args, ret):
				isStringType(ret);
			case TAbstract(t1, params):
				var impl = t1.get().impl;
				if (impl == null)
					return false;
				impl.get().name == "String";
			case TInst(t, params):
				t.get().name == "String";
			case _:
				false;
		}

	public function isStringExpr(e:TypedExprDef):Bool
		return switch(e)
		{
			case TConst(c):
				switch(c)
				{
					case TString(s):
						true;
					case _:
						false;
				}
			case TLocal(v):
				isStringType(v.t);
			case TArray(e1, e2):
				isStringExpr(e1.expr);
			case TBinop(op, e1, e2):
				isStringExpr(e1.expr) || isStringExpr(e2.expr);
			case TField(e, fa):
				switch(fa)
				{
					case FInstance(c, params, cf):
						isStringType(cf.get().type);
					case FStatic(c, cf):
						isStringType(cf.get().type);
					case FAnon(cf):
						isStringType(cf.get().type);
					case FClosure(c, cf):
						isStringType(cf.get().type);
					case FEnum(e, ef):
						isStringType(ef.type);
					case _:
						false;
				}
			case TParenthesis(e):
				isStringExpr(e.expr);
			case TCall(e, el):
				isStringExpr(e.expr);
			case TBlock(el):
				el.length > 0 && isStringExpr(el[el.length-1].expr);
			case TCast(e, m):
				switch(m)
				{
					case TClassDecl(c):
						c.get().name == "String";
					case _:
						false;
				}
			case TReturn(e):
				e != null && isStringExpr(e.expr);
			case _:
				false;
		}

	public function compileOperatorImpl(op:Binop, e1:TypedExpr, e2:TypedExpr)
	{
		return switch(op)
		{
			case OpAdd: 
				if (isStringExpr(e1.expr) || isStringExpr(e2.expr))
					return "..";
				"+";
			case OpMult: "*";
			case OpDiv: "/";
			case OpSub: "-";
			case OpAssign: "=";
			case OpAssignOp(op): compileOperatorImpl(op, e1, e2) + "=";
			case OpEq: "==";
			case OpNotEq: "~=";
			case OpGt: ">";
			case OpGte: ">=";
			case OpLt: "<";
			case OpLte: "<=";
			case OpBoolAnd: "and";
			case OpBoolOr: "or";
			case OpMod: "%";
			case OpIn: "in";
			case OpNullCoal: "or";

			// Moved to src/rluacompiler/preprocessors/implementations/ConvertBitwiseOperators.hx
			//  Lua 5.1 does not have bitwise operators, patch using the bit library instead
			//  still keeping this here for other subsets which do support bitwise operators like Lua 5.3
			case OpAnd: "&";
			case OpOr: "|";
			case OpXor: "^";
			case OpShl: "<<";
			case OpShr: ">>";
			case OpUShr: ">>";
			default:
				throw '$op has not yet been defined to be compiled';
		};
	}

	public function parseUntypedSyntaxCode(el:Array<TypedExpr>):Null<String>
	{
		if (el.length == 0)
			return "";

		var codeTemplate = switch (el[0].expr)
		{
			case TConst(TString(s)): s;
			default:
				throw new haxe.exceptions.ArgumentException("First argument to Syntax.code must be a string literal");
		}

		var args = el.slice(1).map(arg -> compileExpressionImpl(arg, 1));

		var result = StringTools.replace(codeTemplate, '{this}', "self");
		for (i in 0...args.length)
			result = StringTools.replace(result, '{$i}', args[i]);

		return result;
	}
}

#end