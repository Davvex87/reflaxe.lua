package rluacompiler.subcompilers;

#if (macro || rlua_runtime)
import rluacompiler.utils.LuaVUtils;
import reflaxe.DirectToStringCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;
import reflaxe.ReflectCompiler;
import haxe.macro.Expr;
import rluacompiler.utils.CodeBuf;
import haxe.macro.Type;
import haxe.macro.TypedExprTools;
import reflaxe.helpers.ArrayHelper;

using rluacompiler.utils.ModuleUtils;
using StringTools;

class Expressions extends SubCompiler
{
	function getOpProxy(op:Binop):Null<String>
		return switch (op)
		{
			case OpAnd: LuaVUtils.bitFuncField.opAnd;
			case OpOr: LuaVUtils.bitFuncField.opOr;
			case OpXor: LuaVUtils.bitFuncField.opXor;
			case OpShl: LuaVUtils.bitFuncField.opShl;
			case OpShr: LuaVUtils.bitFuncField.opShr;
			case OpUShr: LuaVUtils.bitFuncField.opUShr;
			case _: null;
		}

	var exprDepth:Int = 0;

	public function compileExpressionImpl(expr:TypedExpr, depth:Int, ?previous:TypedExpr):Null<String>
	{
		function exprImpl(e:TypedExpr, depthOffset:Int = 0):Null<String>
			return compileExpressionImpl(e, depth + depthOffset, expr);

		return switch (expr.expr)
		{
			case TConst(c):
				switch (c)
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
				var num = switch (e2.expr)
				{
					case TConst(c):
						switch (c)
						{
							case TInt(i):
								i;
							case _:
								null;
						}
					case _:
						null;
				}
				var m = getTypeMetadatas(e1.t);
				var arr = m?.has(":luaIndexArray");
				var finalV = null;
				exprDepth++;
				if (num != null)
					finalV = '${exprImpl(e1)}[${num + (arr ? 1 : 0)}]';
				else
					finalV = '${exprImpl(e1)}[${exprImpl(e2)}${arr ? '+1' : ''}]';
				exprDepth--;
				return finalV;

			case TBinop(op, e1, e2):
				switch (op)
				{
					case OpAssignOp(op):
						var opFnCall = getOpProxy(op);
						var finalV = null;
						exprDepth++;
						if (opFnCall != null)
							finalV = '${exprImpl(e1)} = ${StringTools.replace(LuaVUtils.bitFuncPattern, "{op}", opFnCall)}(${exprImpl(e1)}, ${exprImpl(e2)})';
						else
							finalV = '${exprImpl(e1)} = ${exprImpl(e1)} ${compileOperatorImpl(op, e1, e2)} ${exprImpl(e2)}';
						exprDepth--;
						return finalV;
					default:
						var opFnCall = getOpProxy(op);
						var finalV = null;
						exprDepth++;
						if (opFnCall != null)
							finalV = '${StringTools.replace(LuaVUtils.bitFuncPattern, "{op}", opFnCall)}(${exprImpl(e1)}, ${exprImpl(e2)})';
						else
							finalV = '${exprImpl(e1)} ${compileOperatorImpl(op, e1, e2)} ${exprImpl(e2)}';
						exprDepth--;
						return finalV;
				}

			case TField(e, fa):
				var finalV = null;
				exprDepth++;
				switch (fa)
				{
					case FInstance(c, params, cf):
						var field = cf.get();
						var accessor = switch (field.kind)
						{
							case FMethod(_) if (!e.expr.match(TConst(TSuper))): ":";
							case FVar(_, _): ".";
							default: ".";
						}
						var code = main.compileNativeVariableCodeMetaWithAccessor(e, field.name, accessor);
						if (code != null) finalV = code; else finalV = '${exprImpl(e)}${accessor}${field.name}';
					case FStatic(c, cf):
						var clsf = cf.get();
						var code = main.compileNativeVariableCodeMetaWithAccessor(e, clsf.name, ".");
						if (code != null)
							finalV = code;
						{
							var cls = c.get();
							if (cls.name.endsWith("_Fields_") && clsf.isExtern)
								finalV = clsf.name;
							else if (cls.name.length == 0)
								finalV = clsf.name;
							else
								finalV = '${cls.extractName()}.${clsf.name}';
						}
					case FAnon(cf):
						var accessor = switch (cf.get().kind)
						{
							case FMethod(_) if (!e.expr.match(TConst(TSuper))): ":";
							case FVar(_, _): ".";
							default: ".";
						}
						finalV = '${exprImpl(e)}$accessor${cf.get().name}';
					case FDynamic(s):
						finalV = '${exprImpl(e)}.${s}';
					case FClosure(c, cf):
						finalV = '${exprImpl(e)}.${cf.get().name}';
					case FEnum(e, ef):
						finalV = '${e.get().extractName()}.${ef.name}';
				}
				exprDepth--;
				return finalV;

			case TTypeExpr(m):
				switch (m)
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
				var finalV = null;
				exprDepth++;
				finalV = '(${exprImpl(e)})';
				exprDepth--;
				return finalV;

			case TObjectDecl(fields):
				exprDepth++;
				var fieldStrs = fields.map(f -> '${f.name} = ${exprImpl(f.expr)}');
				exprDepth--;
				if (fieldStrs.length == 0)
					return '{}';

				var buff:CodeBuf = new CodeBuf();

				buff += '{${buff.enter}';
				buff += fieldStrs.join(",\n");
				buff += '${buff.leave}}';
				buff;

			case TArrayDecl(el):
				exprDepth++;
				var elements = el.map(e -> exprImpl(e));
				exprDepth--;
				'{${elements.join(", ")}}';

			case TCall(e, el):
				var code = main.compileNativeFunctionCodeMeta(e, el);
				if (code != null)
					return code;

				switch (e.expr)
				{
					case TIdent(s):
						switch (s)
						{
							case "__lua__":
								return parseUntypedSyntaxCode(el);
							case _:
						}

					case TField(e, fa):
						switch (fa)
						{
							case FStatic(c, cf):
								if (c.get().name == "Syntax" && cf.get().name == "code") return parseUntypedSyntaxCode(el);
							case _:
						}
					case _:
				};
				exprDepth++;
				var field = exprImpl(e);

				var isSuperCall:Bool = field.startsWith("self.__super__");

				if (field == "self.__super__")
					field += ".__constructor";

				var args = el.map(arg -> exprImpl(arg));
				if (isSuperCall)
					args.insert(0, "self");
				exprDepth--;
				'$field(${args.join(", ")})';

			case TNew(c, params, el):
				var code = main.compileNativeFunctionCodeMeta(expr, el);
				if (code != null)
					return code;
				exprDepth++;
				var args = el.map(arg -> exprImpl(arg));
				exprDepth--;
				'${c.get().name}.new(${args.join(", ")})';

			case TUnop(op, postFix, e):
				switch (op)
				{
					case OpIncrement:
						exprDepth++;
						var exprStr = exprImpl(e);
						exprDepth--;
						if (exprDepth == 0)
							return '${exprStr} = ${exprStr} + 1;';
						if (postFix)
						{
							var tempVar = '__temp_${Std.random(100000)}';
							'(function() local ${tempVar} = ${exprStr}; ${exprStr} = ${exprStr} + 1; return ${tempVar} end)()';
						}
						else '(function() ${exprStr} = ${exprStr} + 1; return ${exprStr} end)()';

					case OpDecrement:
						exprDepth++;
						var exprStr = exprImpl(e);
						exprDepth--;
						if (exprDepth == 0)
							return '${exprStr} = ${exprStr} - 1;';

						if (postFix)
						{
							var tempVar = '__temp_${Std.random(100000)}';
							'(function() local ${tempVar} = ${exprStr}; ${exprStr} = ${exprStr} - 1; return ${tempVar} end)()';
						}
						else '(function() ${exprStr} = ${exprStr} - 1; return ${exprStr} end)()';

					case OpNot:
						var finalV = null;
						exprDepth++;
						finalV = 'not ${exprImpl(e)}';
						exprDepth--;
						return finalV;

					case OpNeg:
						var finalV = null;
						exprDepth++;
						finalV = '-${exprImpl(e)}';
						exprDepth--;
						return finalV;

					case OpNegBits:
						var finalV = null;
						exprDepth++;
						finalV = '${StringTools.replace(LuaVUtils.bitFuncPattern, "{op}", LuaVUtils.bitFuncField.opNegBits)}(${exprImpl(e)})';
						exprDepth--;
						return finalV;

					default:
						throw 'Unary operator ${op} not implemented';
				}

			case TFunction(tfunc):
				var buff:CodeBuf = new CodeBuf();
				var args = tfunc.args.map(arg -> switch (arg.v.t)
				{
					case TInst(t, _) if (t.get().name == "Rest" && ArrayHelper.equals(t.get().pack, ["haxe"])):
						"...";
					default:
						arg.v.name;
				});
				var body = exprImpl(tfunc.expr, 1);

				buff += '(function(${args.join(", ")})${buff.enter}';
				buff += body;
				buff += '${buff.leave}end)';
				buff;

			case TVar(v, expr):
				var finalV = null;
				exprDepth++;
				if (expr != null)
					finalV = 'local ${v.name} = ${exprImpl(expr)}';
				else
					finalV = 'local ${v.name}';
				exprDepth--;
				return finalV;

			case TBlock(el):
				var alreadyHasBlock = previous != null && switch (previous.expr)
				{
					case TBlock(_): true;
					case TFor(_, _, _): true;
					case TIf(_, _, _): true;
					case TFunction(_): true;
					case TWhile(_, _, _): true;
					case TSwitch(_, _, _): true;
					case TTry(_, _): true;
					default: false;
				} var statements = el.map(e ->
				{
					var curDepth = exprDepth;
					exprDepth -= curDepth;
					var compiled = exprImpl(e, alreadyHasBlock ? 0 : 1);
					exprDepth += curDepth;
					return compiled;
					// return alreadyHasBlock ? compiled : indent(depth + 1) + compiled;
				});

				if (statements.length < 1)
					return "";

				var buff:CodeBuf = new CodeBuf();

				if (depth == 0 || alreadyHasBlock)
					buff += statements.join('\n');
				else
				{
					// buff += 'do\n${statements.join('\n')}\nend';
					buff += 'do${buff.enter}';
					buff += statements.join('\n');
					buff += '${buff.leave}end';
				}

				buff;

			case TFor(v, e1, e2):
				var buff:CodeBuf = new CodeBuf();

				exprDepth++;
				var body = exprImpl(e2, 1);
				exprDepth--;

				var curDepth = exprDepth;
				exprDepth -= curDepth;
				// 'for ${v.name} in ${exprImpl(e1)} do\n${body}\nend';
				buff += 'for ${v.name} in ${exprImpl(e1)} do${buff.enter}';
				exprDepth += curDepth;
				buff += body;
				buff += '${buff.leave}end';
				buff;

			case TIf(econd, eif, eelse):
				var buff:CodeBuf = new CodeBuf();

				exprDepth++;
				buff += 'if ${exprImpl(econd)} then${buff.enter}';
				exprDepth--;
				var curDepth = exprDepth;
				exprDepth -= curDepth;
				buff += exprImpl(eif, 1);
				exprDepth += curDepth;

				if (eelse != null && !isEmptyBlock(eelse))
				{
					var nextIsIf = eelse.expr.match(TIf(_, _, _));
					buff += '${buff.leave}else';
					if (!nextIsIf)
						buff += '${buff.enter}';
					var curDepth = exprDepth;
					exprDepth -= curDepth;
					buff += exprImpl(eelse, 1);
					exprDepth += curDepth;
					if (!nextIsIf)
						buff += '${buff.leave}end';
				}
				else
					buff += '${buff.leave}end';

				buff;

			case TWhile(econd, e, normalWhile):
				var buff:CodeBuf = new CodeBuf();

				var curDepth = exprDepth;
				exprDepth -= curDepth;
				var body = exprImpl(e, 1);
				exprDepth += curDepth;
				if (normalWhile)
				{
					exprDepth++;
					buff += 'while ${exprImpl(econd)} do${buff.enter}';
					exprDepth--;
					buff += body;
					buff += '${buff.leave}end';
				}
				else
				{
					buff += 'repeat${buff.enter}';
					buff += body;
					exprDepth++;
					buff += '${buff.leave}until not (${exprImpl(econd)})';
					exprDepth--;
				}

				buff;

			case TSwitch(e, cases, edef):
				// Lua doesn't have switch, so we'll compile to if-elseif chain
				var buff:CodeBuf = new CodeBuf();
				exprDepth++;
				var switchVar = exprImpl(e);
				exprDepth--;
				var result = "";
				var first = true;

				for (c in cases)
				{
					exprDepth++;
					var conditions = c.values.map(v -> '${switchVar} == ${exprImpl(v)}');
					exprDepth--;
					var condStr = conditions.join(' or ');
					var curDepth = exprDepth;
					exprDepth -= curDepth;
					var caseBody = exprImpl(c.expr, 1);
					exprDepth += curDepth;

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
					var curDepth = exprDepth;
					exprDepth -= curDepth;
					buff += exprImpl(edef, 1);
					exprDepth += curDepth;
				}

				buff += '${buff.leave}end';
				buff;

			case TTry(e, catches):
				// Lua doesn't have try-catch, we'll use pcall
				var buff:CodeBuf = new CodeBuf();

				var hasReturn = getReturnExpr(e) != null;

				buff += 'local success, result = pcall(function()${buff.enter}';
				var curDepth = exprDepth;
				exprDepth -= curDepth;
				buff += exprImpl(e);
				exprDepth += curDepth;
				buff += '${buff.leave}end)\n';

				if (catches.length > 0)
				{
					buff += 'if not success then${buff.enter}';
					for (c in catches)
					{
						var curDepth = exprDepth;
						exprDepth -= curDepth;
						var catchBody = exprImpl(c.expr, 1);
						exprDepth += curDepth;
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
				var finalV = null;
				exprDepth++;
				if (e != null)
					finalV = 'return ${exprImpl(e)}';
				else
					finalV = 'return';
				exprDepth--;
				finalV;

			case TBreak:
				'break';

			case TContinue:
				'goto continue'; // Lua 5.2+ has goto

			case TThrow(e):
				var finalV = null;
				exprDepth++;
				finalV = 'error(${exprImpl(e)})';
				exprDepth--;
				finalV;

			case TCast(e, m):
				// In Lua, casting is usually just returning the value
				exprImpl(e);

			case TMeta(m, e1):
				// Metadata is usually ignored in compilation
				exprImpl(e1);

			case TEnumParameter(e1, ef, index):
				'${exprImpl(e1)}[${index + 1}]'; // Lua arrays are 1-indexed

			case TEnumIndex(e1):
				'${exprImpl(e1)}._index';

			case TIdent(s):
				s;

			default:
				null; // throw new NotImplementedException('${expr.expr} has not yet been defined to be compiled');
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

	public function isEmptyBlock(expr:TypedExpr)
		return switch (expr.expr)
		{
			case TBlock(el):
				el.length == 0;
			case _:
				false;
		}

	public function isArrayType(t:Type)
		return switch (t)
		{
			case TMono(t):
				isArrayType(t.get());
			case TFun(args, ret):
				isArrayType(ret);
			case TAbstract(t1, params):
				var impl = t1.get().impl;
				if (impl == null)
					return false;
				impl.get().name == "Array";
			case TInst(t, params):
				t.get().name == "Array";
			case _:
				false;
		}

	public function isStringType(t:Type)
		return switch (t)
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
		return switch (e)
		{
			case TConst(c):
				switch (c)
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
			case TBinop(op, e1, e2): isStringExpr(e1.expr) || isStringExpr(e2.expr);
			case TField(e, fa):
				switch (fa)
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
			case TBlock(el): el.length > 0 && isStringExpr(el[el.length - 1].expr);
			case TCast(e, m):
				switch (m)
				{
					case TClassDecl(c):
						c.get().name == "String";
					case _:
						false;
				}
			case TReturn(e): e != null && isStringExpr(e.expr);
			case _:
				false;
		}

	public function getTypeMetadatas(t:Type):Null<MetaAccess>
		return switch (t)
		{
			case TMono(ty):
				getTypeMetadatas(ty.get());
			case TEnum(t, _):
				t.get().meta;
			case TInst(t, _):
				t.get().meta;
			case TType(t, _):
				t.get().meta;
			case TFun(_, _):
				null;
			case TAnonymous(_):
				null;
			case TDynamic(ty):
				if (ty == null) null; else getTypeMetadatas(ty);
			case TLazy(_):
				null;
			case TAbstract(t, _):
				t.get().meta;
		}

	public function compileOperatorImpl(op:Binop, e1:TypedExpr, e2:TypedExpr)
	{
		return switch (op)
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
