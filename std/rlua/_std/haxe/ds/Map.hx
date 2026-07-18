/*
 * Copyright (C)2005-2019 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package haxe.ds;

import haxe.ds.StringMap;
import haxe.ds.IntMap;
import haxe.ds.ObjectMap;
import haxe.ds.EnumValueMap;
import haxe.Constraints.IMap;
import haxe.iterators.ArrayIterator;
import haxe.iterators.DynamicAccessIterator;
import haxe.iterators.DynamicAccessKeyValueIterator;
import rlua.Table;

/**
	Map allows key to value mapping for arbitrary value types, and many key
	types.

	This is a multi-type abstract, it is instantiated as one of its
	specialization types depending on its type parameters.

	A Map can be instantiated without explicit type parameters. Type inference
	will then determine the type parameters from the usage.

	Maps can also be created with `[key1 => value1, key2 => value2]` syntax.

	Map is an abstract type, it is not available at runtime.

	@see https://haxe.org/manual/std-Map.html
**/
@:runtimeValue abstract Map<K, V>(TableMap<K, V>)
{
	public inline function new()
		this = untyped {};

	@:from
	public static inline function fromTable<K, V>(t:LuaTable<K, V>):Map<K, V>
		return cast t;

	@:to
	public inline function toTable():LuaTable<K, V>
		return cast this;

	@:from
	public static inline function fromArray<V>(a:Array<V>):Map<Int, V>
		return cast a;

	@:to
	public inline function toArray():Array<V>
		return cast this;

	@:from
	public static inline function fromDynamic<K, V>(d:Dynamic<V>):Map<K, V>
		return cast d;

	@:to
	public inline function toDynamic():Dynamic<V>
		return cast this;

	@:arrayAccess
	public inline function get(k:K):Null<V>
		return untyped this[k];

	@:arrayAccess
	public inline function set(k:K, v:V):Void
		return untyped this[k] = v;

	public inline function exists(k:K):Bool
		return k == null || untyped this[k] != null;

	public function remove(k:K):Bool
	{
		if (!exists(k))
			return false;
		untyped this[k] = null;
		return true;
	}

	public inline function keys():Iterator<K>
	{
		var r = [];
		untyped __lua__("for k in pairs({0}) do table.insert({1}, k) end", this, r);
		return new ArrayIterator(r);
	}

	public inline function iterator():Iterator<V>
	{
		var itr = keys();
		return untyped {
			hasNext: itr.hasNext,
			next: function() return h[itr.next()]
		};
	}

	public inline function keyValueIterator():KeyValueIterator<K, V>
	{
		return new haxe.iterators.MapKeyValueIterator(this);
	}

	public inline function copy():IMap<K, V>
		return Reflect.copy(this);

	public function toString():String
	{
		var s = new StringBuf();
		s.add("[");
		var it = keys();
		for (i in it)
		{
			s.add(i);
			s.add(" => ");
			s.add(Std.string(get(i)));
			if (it.hasNext())
				s.add(", ");
		}
		s.add("]");
		return s.toString();
	}

	public function clear():Void
	{
		untyped __lua__("for k, _ in pairs({0}) do {0}[k] = nil end", this);
	}
}

extern class TableMap<K, V> extends LuaTable<K, V> implements IMap<K, V>
{
	function new();
	function get(k:K):Null<V>;
	function set(k:K, v:V):Void;
	function exists(k:K):Bool;
	function remove(k:K):Bool;
	function keys():Iterator<K>;
	function iterator():Iterator<V>;
	function keyValueIterator():KeyValueIterator<K, V>;
	function copy():IMap<K, V>;
	function toString():String;
	function clear():Void;
}
