package rluacompiler.subcompilers;

import reflaxe.ReflectCompiler;
import haxe.macro.Expr.Binop;
#if (macro || rlua_runtime)

import haxe.exceptions.NotImplementedException;

import haxe.macro.Type;

// Import Reflaxe types
import reflaxe.DirectToStringCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;

class Expressions extends SubCompiler {
	
	private function indent(depth: Int): String {
		return [for (_ in 0...depth) "\t"].join("");
	}
	
	private var _tabs:Int = 1;
	private function indentLines(str: String): String {
		if (_tabs == 0) return str;
		var lines = str.split("\n");
		return lines.map(line -> line.length > 0 ? indent(_tabs) + line : line).join("\n");
	}

	public function compileExpressionImpl(expr: TypedExpr, depth: Int, ?previous:TypedExpr): Null<String>
	{
		function exprImpl(e:TypedExpr, depthOffset:Int = 0): Null<String>
			return compileExpressionImpl(e, depth + depthOffset, expr);

		var result:Null<String> = switch(expr.expr)
		{
			case TConst(c):
				switch(c)
				{
					case TInt(i):
						Std.string(i);

					case TFloat(s):
						Std.string(s);

					case TString(s):
						'"$s"';

					case TBool(b):
						Std.string(b);

					case TNull:
						"nil";

					case TThis:
						"self";

					case TSuper:
						"self.super";

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
					return '${exprImpl(e1)}[${num+1}]';
				'${exprImpl(e1)}[${exprImpl(e2)}+1]';

			case TBinop(op, e1, e2):
				switch(op)
				{
					case OpAssignOp(op):
						var opr = compileOperatorImpl(op, e1, e2);
						return '${exprImpl(e1)} = ${exprImpl(e1)} ${opr} ${exprImpl(e2)}';
					case _:
				}
				var opr = compileOperatorImpl(op, e1, e2);
				'${exprImpl(e1)} ${opr} ${exprImpl(e2)}';

			/**
				Field access on `e` according to `fa`.
			**/
			case TField(e, fa):
				switch(fa) {
					case FInstance(c, params, cf):
						var field = cf.get();
						var accessor = switch(field.kind) {
							case FMethod(_): ":";
							case FVar(_, _): ".";
							default: ".";
						}
						'${exprImpl(e)}${accessor}${field.name}';

					case FStatic(c, cf):
						if (c.get().name.length == 0)
							return cf.get().name;

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

			/**
				Reference to a module type `m`.
			**/
			case TTypeExpr(m):
				switch(m) {
					case TClassDecl(c):
						c.get().name;
					case TEnumDecl(e):
						e.get().name;
					case TTypeDecl(t):
						t.get().name;
					case TAbstract(a):
						a.get().name;
				}

			/**
				Parentheses `(e)`.
			**/
			case TParenthesis(e):
				'(${exprImpl(e)})';

			/**
				An object declaration.
			**/
			case TObjectDecl(fields):
				var fieldStrs = fields.map(f -> '${f.name} = ${exprImpl(f.expr)}');
				_tabs++;
				var res = '{\n${indentLines(fieldStrs.join(",\n"))}\n\t}';
				_tabs--;
				res;

			/**
				An array declaration `[el]`.
			**/
			case TArrayDecl(el):
				el.map(e -> trace(e.expr));
				var elements = el.map(e -> exprImpl(e));
				trace(elements);
				'{${elements.join(", ")}}';

			/**
				A call `e(el)`.
			**/
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
				}

				var args = el.map(arg -> exprImpl(arg));
				'${exprImpl(e)}(${args.join(", ")})';

			/**
				A constructor call `new c<params>(el)`.
			**/
			case TNew(c, params, el):
				var code = main.compileNativeFunctionCodeMeta(expr, el);
				if (code != null)
					return code;

				var args = el.map(arg -> exprImpl(arg));
				'${c.get().name}.new(${args.join(", ")})';

			/**
				An unary operator `op` on `e`:

				* e++ (op = OpIncrement, postFix = true)
				* e-- (op = OpDecrement, postFix = true)
				* ++e (op = OpIncrement, postFix = false)
				* --e (op = OpDecrement, postFix = false)
				* -e (op = OpNeg, postFix = false)
				* !e (op = OpNot, postFix = false)
				* ~e (op = OpNegBits, postFix = false)
			**/
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
						
					case OpNegBits:
						var exprStr = exprImpl(e);
						'bit.bnot(${exprStr})';
						
					default:
						throw new NotImplementedException('Unary operator ${op} not implemented');
				}

			/**
				A function declaration.
			**/
			case TFunction(tfunc):
				var args = tfunc.args.map(arg -> arg.v.name);
				var body = indentLines(exprImpl(tfunc.expr, 1));
				'function(${args.join(", ")})\n${body}\n${indent(depth)}end';

			/**
				A variable declaration `var v` or `var v = expr`.
			**/
			case TVar(v, expr):
				if (expr != null) {
					'local ${v.name} = ${exprImpl(expr)}';
				} else {
					'local ${v.name}';
				}

			/**
				A block declaration `{el}`.
			**/
			case TBlock(el):
				//_tabs++;
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
					return alreadyHasBlock ? compiled : indent(depth + 1) + compiled;
				});
				//_tabs--;
				
				if (statements.length < 1) return "";

				var res = "";

				if (depth == 0 || alreadyHasBlock)
					res = statements.join('\n');
				else
					res = 'do\n${statements.join('\n')}\n${indent(_tabs)}end';

				return res;

			/**
				A `for` expression.
			**/
			case TFor(v, e1, e2):
				var body = indentLines(exprImpl(e2, 1));
				'for ${v.name} in ${exprImpl(e1)} do\n${body}\n${indent(depth)}end';

			/**
				An `if(econd) eif` or `if(econd) eif else eelse` expression.
			**/
			case TIf(econd, eif, eelse):
				_tabs++;
				var ifBody = indentLines(exprImpl(eif, 1));
				var result = 'if ${exprImpl(econd)} then\n${ifBody}';
				if (eelse != null) {
					var elseBody = indentLines(exprImpl(eelse, 1));
					_tabs--;
					result += '\n${indent(depth)}else\n${elseBody}';
				}
				_tabs++;
				var result1 = result + '\n${indent(depth)}end';
				_tabs--;
				result1;

			/**
				Represents a `while` expression.
				When `normalWhile` is `true` it is `while (...)`.
				When `normalWhile` is `false` it is `do {...} while (...)`.
			**/
			case TWhile(econd, e, normalWhile):
				var body = indentLines(exprImpl(e, 1));
				if (normalWhile) {
					'while ${exprImpl(econd)} do\n${body}\n${indent(depth)}end';
				} else {
					'repeat\n${body}\n${indent(depth)}until not (${exprImpl(econd)})';
				}

			/**
				Represents a `switch` expression with related cases and an optional
				`default` case if edef != null.
			**/
			case TSwitch(e, cases, edef):
				// Lua doesn't have switch, so we'll compile to if-elseif chain
				var switchVar = exprImpl(e);
				var result = "";
				var first = true;
				
				for (case_ in cases) {
					_tabs++;
					var conditions = case_.values.map(v -> '${switchVar} == ${exprImpl(v)}');
					var condStr = conditions.join(' or ');
					var caseBody = indentLines(exprImpl(case_.expr, 1));
					
					if (first) {
						result += 'if ${condStr} then\n${caseBody}';
						first = false;
					} else {
						result += '\n${indent(depth)}elseif ${condStr} then\n${caseBody}';
					}
					_tabs--;
				}
				
				if (edef != null) {
					var defaultBody = indentLines(exprImpl(edef, 1));
					result += '\n${indent(depth)}else\n${defaultBody}';
				}
				
				result + '\n${indent(depth)}end';

			/**
				Represents a `try`-expression with related catches.
			**/
			case TTry(e, catches):
				// Lua doesn't have try-catch, we'll use pcall
				var tryBody = exprImpl(e);
				var result = 'local success, result = pcall(function() return ${tryBody} end)';
				
				if (catches.length > 0) {
					result += '\n${indent(depth)}if not success then';
					for (catch_ in catches) {
						var catchBody = indentLines(exprImpl(catch_.expr, 1));
						result += '\n${indent(depth + 1)}local ${catch_.v.name} = result';
						result += '\n${catchBody}';
					}
					result += '\n${indent(depth)}else\n${indent(depth + 1)}return result\n${indent(depth)}end';
				}
				
				result;

			/**
				A `return` or `return e` expression.
			**/
			case TReturn(e):
				if (e != null) {
					'return ${exprImpl(e)}';
				} else {
					'return';
				}

			/**
				A `break` expression.
			**/
			case TBreak:
				'break';

			/**
				A `continue` expression.
			**/
			case TContinue:
				'goto continue'; // Lua 5.2+ has goto

			/**
				A `throw e` expression.
			**/
			case TThrow(e):
				'error(${exprImpl(e)})';

			/**
				A `cast e` or `cast (e, m)` expression.
			**/
			case TCast(e, m):
				// In Lua, casting is usually just returning the value
				exprImpl(e);

			/**
				A `@m e1` expression.
			**/
			case TMeta(m, e1):
				// Metadata is usually ignored in compilation
				exprImpl(e1);

			/**
				Access to an enum parameter (generated by the pattern matcher).
			**/
			case TEnumParameter(e1, ef, index):
				'${exprImpl(e1)}[${index + 1}]'; // Lua arrays are 1-indexed

			/**
				Access to an enum index (generated by the pattern matcher).
			**/
			case TEnumIndex(e1):
				'${exprImpl(e1)}.index';

			/**
				An unknown identifier.
			**/
			case TIdent(s):
				s;

			default:
				null;//throw new NotImplementedException('${expr.expr} has not yet been defined to be compiled');
		}
		return result;
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
				isStringExpr(el[el.length-1].expr);
			case TCast(e, m):
				switch(m)
				{
					case TClassDecl(c):
						c.get().name == "String";
					case _:
						false;
				}
			case TReturn(e):
				isStringExpr(e.expr);
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
			default:
				throw new NotImplementedException('$op has not yet been defined to be compiled');
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