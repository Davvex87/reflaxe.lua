package;

import rlua.LuaStringTools;

extern class String
{
	var length(get, never):Int;

	@:nativeFunctionCode("#{this}")
	function get_length():Int;

	@:nativeFunctionCode("{arg0}")
	function new(string:String);

	@:native("lower")
	function toUpperCase():String;

	@:native("upper")
	function toLowerCase():String;

	inline function charAt(index:Int):String
		return untyped string.sub(this, index + 1, index + 1);

	inline function charCodeAt(index:Int):Null<Int>
		return untyped #if lua_utf8 utf8.codepoint(this, index + 1) #else string.byte(this, index + 1) #end;

	inline function indexOf(str:String, ?startIndex:Int):Int
		return untyped __lua__("string.find({0}, {1}, ({2} or 0)+1, true) - 1 or -1", this, str, startIndex);

	inline function lastIndexOf(str:String, ?startIndex:Int):Int
		return LuaStringTools.lastIndexOf(this, str, startIndex);

	inline function split(delimiter:String):Array<String>
		return LuaStringTools.split(this, delimiter);

	@:nativeFunctionCode("string.sub({this}, {arg0} + 1, {arg0} + ({arg1} or (#{this} - {arg0} + 1)))")
	function substr(pos:Int, ?len:Int):String;

	@:nativeFunctionCode("string.sub({this}, ({arg0} or 0) + 1, ({arg1} or 1))")
	function substring(startIndex:Int, ?endIndex:Int):String;

	@:nativeFunctionCode("tostring({this})")
	function toString():String;

	@:nativeFunctionCode("string.char({arg0})")
	@:pure static function fromCharCode(code:Int):String;
}
