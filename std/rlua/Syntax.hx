package rlua;

import haxe.extern.Rest;

/**
	Use this class to provide special features for your target's syntax.
	The implementations for these functions can be implemented in your compiler.

	For more info, visit:
		src/rluacompiler/Compiler.hx
**/
extern class Syntax {
	public static function code(code:String, args:Rest<Dynamic>): Void;
}
