package rlua;

import rlua.Table;

/**
	A set of utility methods for working with the Lua table extern.
**/
class PairTools
{
	public static function ipairsEach<T>(table:LuaTable<Dynamic, T>, func:Int->T->Void):Void
	{
		untyped __lua__("for i,v in ipairs(table) do func(i,v) end");
	}

	public static function pairsEach<A, B>(table:LuaTable<A, B>, func:A->B->Void):Void
	{
		untyped __lua__("for k,v in pairs(table) do func(k,v) end");
	}

	public static function ipairsMap<A, B>(table:LuaTable<Dynamic, A>, func:Int->A->B):LuaTable<Int, B>
	{
		var ret:LuaTable<Int, B> = Table.create();
		untyped __lua__("for i,v in ipairs(table) do ret[i] = func(i,v) end");
		return ret;
	}

	public static function pairsMap<A, B, C>(table:LuaTable<A, B>, func:A->B->C->C):LuaTable<A, C>
	{
		var ret:LuaTable<A, C> = Table.create();
		untyped __lua__("for k,v in pairs(table) do ret[k] = func(k,v) end");
		return ret;
	}

	public static function ipairsFold<A, B>(table:LuaTable<Int, A>, func:Int->A->B->B, seed:B):B
	{
		untyped __lua__("for i,v in ipairs(table) do seed = func(i,v,seed) end");
		return untyped __lua__("seed");
	}

	public static function pairsFold<A, B, C>(table:LuaTable<A, B>, func:A->B->C->C, seed:C):C
	{
		untyped __lua__("for k,v in pairs(table) do seed = func(k,v,seed) end");
		return untyped __lua__("seed");
	}

	public static function ipairsConcat<T>(table1:LuaTable<Int, T>, table2:LuaTable<Int, T>)
	{
		var ret:LuaTable<Int, T> = Table.create();
		ipairsFold(table1, function(a, b, c:LuaTable<Int, T>)
		{
			c[a] = b;
			return c;
		}, ret);
		var size = ret.length;
		ipairsFold(table2, function(a, b, c:LuaTable<Int, T>)
		{
			c[a + size] = b;
			return c;
		}, ret);
		return ret;
	}

	public static function pairsMerge<A, B>(table1:LuaTable<A, B>, table2:LuaTable<A, B>)
	{
		var ret = copy(table1);
		pairsEach(table2, function(a, b:B) ret[cast a] = b);
		return ret;
	}

	public static function ipairsExist<T>(table:LuaTable<Int, T>, func:Int->T->Bool)
	{
		untyped __lua__("for k,v in ipairs(table) do if func(k,v) then return true end end");
	}

	public static function pairsExist<A, B>(table:LuaTable<A, B>, func:A->B->Bool)
	{
		untyped __lua__("for k,v in pairs(table) do if func(k,v) then return true end end");
	}

	public static function copy<A, B>(table1:LuaTable<A, B>):LuaTable<A, B>
	{
		var ret:LuaTable<A, B> = Table.create();
		untyped __lua__("for k,v in pairs(table1) do ret[k] = v end");
		return ret;
	}

	public static function pairsIterator<A, B>(table:LuaTable<A, B>):Iterator<{index:A, value:B}>
	{
		var p = Lua.pairs(table);
		var next = p.next;
		var i = p.index;
		return {
			next: function()
			{
				var res = next(table, i);
				i = res.index;
				return {index: res.index, value: res.value};
			},
			hasNext: function()
			{
				return Lua.next(table, i).value != null;
			}
		}
	}

	public static function ipairsIterator<A, B>(table:LuaTable<A, B>):Iterator<{index:Int, value:B}>
	{
		var p = Lua.ipairs(table);
		var next = p.next;
		var i = p.index;
		return {
			next: function()
			{
				var res = next(table, i);
				i = res.index;
				return {index: res.index, value: res.value};
			},
			hasNext: function()
			{
				return next(table, i).value != null;
			}
		}
	}
}
