package rlua;

import haxe.Constraints.IMap;

@:native("table")
// @:luaIndexArray
extern class Table
{
	public static inline function clone<K, V>(table:LuaTable<K, V>):LuaTable<K, V>
	{
		var ret = Table.create();
		untyped __lua__("for k,v in pairs({0}) do {1}[k] = v end", table, ret);
		return ret;
	}

	@:nativeFunctionCode("{}")
	static function create<K, V>():LuaTable<K, V>;

	static function concat<K, V>(table:LuaTable<K, V>, ?sep:String, ?i:Int, ?j:Int):String;

	@:overload(function<K, V>(table:LuaTable<K, V>, value:V):Void {})
	static function insert<K, V>(table:LuaTable<K, V>, ?pos:Int, value:V):Void;

	static function remove<K, V>(table:LuaTable<K, V>, ?pos:Int):V;
	static function sort<K, V>(table:LuaTable<K, V>, ?comp:V->V->Bool):Void;

	public var length(get, never):Int;

	@:nativeFunctionCode("#{this}")
	function get_length():Int;
	/*
		public inline function iterator()
			return rlua.PairTools.pairsIterator(this);

		public inline function keyValueIterator()
			return rlua.PairTools.pairsIterator(this);
	 */
}

/*
	typedef LuaTable<K, V> = Dynamic;
	typedef AnyTable = Dynamic;
 */
// typedef LuaTable<K, V> = haxe.DynamicAccess<V>;
extern class LuaTable<K, V> implements Dynamic<V> {}
typedef AnyTable = LuaTable<Dynamic, Dynamic>;
