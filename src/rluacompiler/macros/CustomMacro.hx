package rluacompiler.macros;

import haxe.macro.Compiler;
import haxe.macro.Expr;

class CustomMacro
{
	public static macro function build()
	{
		Compiler.registerCustomDefine({
			define: "lua-bit32",
			doc: "Bitwise operations will use the bit32 library when possible."
		});

		Compiler.registerCustomDefine({
			define: "lua-utf8",
			doc: "String operations will use the utf8 library when possible."
		});

		Compiler.registerCustomDefine({
			define: "lua-safe",
			doc: "All type checking operations at runtime will do deep checks to ensure the correct result is always returned, at the cost of runtime performance.\n\t``no`` - Safe checking is off (default);\n\t``soft`` - Performs only fast checks (ideal);\n\t``full`` - Ensures that type checks return the correct value every time (safest, but heavy);",
			params: ["no", "soft", "full"]
		});

		Compiler.registerCustomMetadata({
			metadata: ":customImport",
			doc: "Marks an extern class to be imported with custom code instead of the default reflaxe.lua provides.",
			params: ["Import code"],
			targets: [Class],
		});

		Compiler.registerCustomMetadata({
			metadata: ":topLevelCall",
			doc: "Marks a function to be called at the top level automatically at the end of the script.",
			targets: [ClassField],
		});

		Compiler.registerCustomMetadata({
			metadata: ":topLevelCode",
			doc: "Marks the code from the specified function to be inserted at the end of the script. The original function field will not be included in the output.",
			targets: [ClassField],
		});

		return null;
	}
}
