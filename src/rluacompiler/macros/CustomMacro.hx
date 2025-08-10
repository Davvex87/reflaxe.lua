package rluacompiler.macros;

import haxe.macro.Expr;

class CustomMacro
{
	public static macro function build()
	{
		haxe.macro.Compiler.registerCustomDefine({
			define: "lua-bit32",
			doc: "Bitwise operations will use the bit32 library when possible."
		});

		haxe.macro.Compiler.registerCustomDefine({
			define: "lua-utf8",
			doc: "String operations will use the utf8 library when possible."
		});

		haxe.macro.Compiler.registerCustomDefine({
			define: "lua-safe",
			doc: "All type checking operations at runtime will do deep checks to ensure the correct result is always returned, at the cost of runtime performance.\n\t``no`` - Safe checking is off (default);\n\t``soft`` - Performs only fast checks (ideal);\n\t``full`` - Ensures that type checks return the correct value every time (safest, but heavy);",
			params: ["no", "soft", "full"]
		});

		return null;
	}
}
