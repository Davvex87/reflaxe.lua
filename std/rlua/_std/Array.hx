package;

import rlua.ArrayTools;
import rlua.Syntax;
import haxe.iterators.ArrayIterator;
import haxe.iterators.ArrayKeyValueIterator;

@:luaIndexArray
extern class Array<T> implements ArrayAccess<T>
{
	var length(get, never):Int;

	@:nativeFunctionCode("#{this}")
	function get_length():Int;

	@:nativeFunctionCode("{}")
	public function new();

	inline function concat(a:Array<T>):Array<T>
		return ArrayTools.concat(this, a);

	@:nativeFunctionCode("table.concat({this}, {arg0})")
	function join(sep:String):String;

	@:nativeFunctionCode("table.remove({this}, #{this})")
	function pop():Null<T>;

	@:nativeFunctionCode("table.insert({this}, {arg0})")
	function push(x:T):Void;

	inline function reverse():Void
		ArrayTools.reverse(this);

	@:nativeFunctionCode("table.remove({this}, 1)")
	function shift():Null<T>;

	inline function slice(pos:Int, ?_end:Int):Array<T>
		return ArrayTools.slice(this, pos, _end);

	@:nativeFunctionCode("table.sort({this}, function(a, b) return {arg0}(a, b) < 0 end)")
	function sort(f:T->T->Int):Void;

	inline function splice(pos:Int, len:Int):Array<T>
		return ArrayTools.splice(this, pos, len);

	@:nativeFunctionCode("table.concat({this}, ', ')")
	function toString():String;

	@:nativeFunctionCode("table.insert({this}, 1, {arg0})")
	function unshift(x:T):Void;

	@:nativeFunctionCode("table.insert({this}, {arg0}+1, {arg1})")
	function insert(pos:Int, x:T):Void;

	inline function remove(x:T):Bool
		return ArrayTools.safeRemove(this, x);

	inline function contains(x:T):Bool
		return ArrayTools.find(this, x) != null;

	inline function indexOf(x:T, ?fromIndex:Int):Int
		return ArrayTools.find(this, x, fromIndex) ?? -1;

	inline function lastIndexOf(x:T, ?fromIndex:Int):Int
		return ArrayTools.rfind(this, x, fromIndex) ?? -1;

	inline function copy():Array<T>
		return ArrayTools.copy(this);

	public inline function iterator():ArrayIterator<T>
		return new ArrayIterator(this);

	public inline function keyValueIterator():ArrayKeyValueIterator<T>
		return new ArrayKeyValueIterator(this);

	inline function map<S>(f:T->S):Array<S>
		return ArrayTools.map(this, f);

	inline function filter(f:T->Bool):Array<T>
		return ArrayTools.filter(this, f);

	inline function resize(len:Int):Void
		ArrayTools.resize(this, len);
}
