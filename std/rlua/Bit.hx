package rlua;

@:native(#if lua_bit32 "bit32" #else "bit" #end)
extern class Bit
{
	static function band(a:Int, b:Int, ...rest:Int):Int;
	static function bor(a:Int, b:Int, ...rest:Int):Int;
	static function bxor(a:Int, b:Int, ...rest:Int):Int;
	static function bnot(a:Int):Int;
	static function lshift(a:Int, n:Int):Int;
	static function rshift(a:Int, n:Int):Int;
	static function arshift(a:Int, n:Int):Int;
	static function rol(a:Int, n:Int):Int;
	static function ror(a:Int, n:Int):Int;
	static function tobit(x:Int):Int;
	static function tohex(x:Int, ?n:Int):Int;

	// FIXME: this just supports the bit library, gotta add the functions from the bit32 as well
}

#if lua_bit32
typedef Bit32 = Bit;
#end
