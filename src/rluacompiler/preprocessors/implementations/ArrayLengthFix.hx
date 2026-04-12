package rluacompiler.preprocessors.implementations;

#if (macro || rlua_runtime)
import reflaxe.BaseCompiler;
import reflaxe.data.ClassFieldData;
import reflaxe.preprocessors.BasePreprocessor;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypedExprTools;
import rluacompiler.utils.LuaVUtils;

class ArrayLengthFix extends BasePreprocessor
{
	var compiler:Compiler;

	public function new() {}

	public function process(data:ClassFieldData, compiler:BaseCompiler)
	{
		this.compiler = cast compiler;
		data.setExpr(processExpr(data.expr));
	}

	public function processExpr(expr:TypedExpr):TypedExpr
	{
		switch (expr.expr)
		{
			case TField(e, fa):
				switch (fa)
				{
					case FInstance(c, params, cf):
						var field = cf.get();
						if (field.name == "length")
						{
							var m = compiler.expressionsSubCompiler.getTypeMetadatas(e.t);
							var arr = m?.has(":luaIndexArray");
							if (arr)
							{
								field.meta.add(":nativeFunctionCode", [{expr: EConst(CString("#{this}")), pos: e.pos}], e.pos);
								var nativeMeta:MetadataEntry = {
									name: ":nativeFunctionCode",
									params: [{expr: EConst(CString("#{this}")), pos: e.pos}],
									pos: e.pos
								};
								var funcMeta:MetaAccess = {
									get: () -> [nativeMeta],
									extract: (name) -> name == ":nativeFunctionCode" ? [nativeMeta] : [],
									add: (name, params, pos) -> {},
									remove: (name) -> {},
									has: (name) -> name == ":nativeFunctionCode"
								};
								var funcField:ClassField = {
									name: "get_length",
									type: e.t,
									isPublic: true,
									isExtern: false,
									isFinal: false,
									isAbstract: false,
									params: [],
									meta: funcMeta,
									kind: FMethod(MethNormal),
									expr: () -> null,
									pos: e.pos,
									doc: null,
									overloads: {
										get: () -> [],
										toString: () -> "[]"
									}
								};
								return {
									expr: TCall({
										expr: TField(e, FInstance(c, params, {get: () -> funcField, toString: () -> "get_length"})),
										t: e.t,
										pos: e.pos
									}, []),
									t: e.t,
									pos: e.pos
								};
							}
						}
					case _:
				}
				return expr;

			default:
				return TypedExprTools.map(expr, processExpr);
		}
	}
}
#end
