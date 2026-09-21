package rluacompiler.utils;

#if (macro || rlua_runtime)
import haxe.macro.Expr;
import haxe.macro.Type.BaseType;

/**
	Helpers for the `@:luaRequire` and `@:customImport` metas.

	Both mark an extern type as being imported by custom code at the top of
	every module that uses it:
	- `@:luaRequire("mod")` emits `local Name = require("mod")` (and
	  `@:luaRequire("mod", "sub")` emits `local Name = require("mod").sub`),
	  matching the original Haxe Lua target;
	- `@:customImport("expr")` emits `local Name = expr` verbatim.
**/
class CustomImportUtils
{
	public static inline function hasCustomImport(bt:BaseType):Bool
	{
		return bt.meta.has(":luaRequire") || bt.meta.has(":customImport");
	}

	/**
		Builds the right-hand side of the `local Name = ...` import line,
		or `null` if the type carries neither meta.
	**/
	public static function resolveCustomImport(bt:BaseType):Null<String>
	{
		if (bt.meta.has(":luaRequire"))
		{
			final params = bt.meta.extract(":luaRequire")[0].params ?? [];
			final parts = params.map(p -> stringOf(p));
			if (parts.length == 0 || parts[0] == null)
				return 'require("${bt.name}")';
			var out = 'require("${parts[0]}")';
			for (i in 1...parts.length)
				if (parts[i] != null)
					out += "." + parts[i];
			return out;
		}

		if (bt.meta.has(":customImport"))
		{
			final params = bt.meta.extract(":customImport")[0].params ?? [];
			return params.length > 0 ? (stringOf(params[0]) ?? bt.name) : bt.name;
		}

		return null;
	}

	static function stringOf(e:Expr):Null<String>
	{
		return switch (e.expr)
		{
			case EConst(CString(s)): s;
			default: null;
		}
	}
}
#end
