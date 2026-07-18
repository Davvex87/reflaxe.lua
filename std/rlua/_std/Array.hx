package;

import rlua.ArrayTools;
import rlua.Syntax;
import rlua.Table;
import haxe.iterators.ArrayIterator;
import haxe.iterators.ArrayKeyValueIterator;

@:luaIndexArray
extern class Array<T> implements ArrayAccess<T>
{
	/**
		The length of `this` Array.
	**/
	@:pure var length(get, never):Int;

	@:nativeFunctionCode("#{this}")
	@:pure function get_length():Int;

	/**
		Creates a new Array.
	**/
	@:nativeFunctionCode("{}")
	public function new();

	/**
		Returns a new Array by appending the elements of `a` to the elements of
		`this` Array.

		This operation does not modify `this` Array.

		If `a` is the empty Array `[]`, a copy of `this` Array is returned.

		The length of the returned Array is equal to the sum of `this.length`
		and `a.length`.

		If `a` is `null`, the result is unspecified.
	**/
	@:pure inline function concat(a:Array<T>):Array<T>
		return ArrayTools.concat(this, a);

	/**
		Returns a string representation of `this` Array, with `sep` separating
		each element.

		The result of this operation is equal to `Std.string(this[0]) + sep +
		Std.string(this[1]) + sep + ... + sep + Std.string(this[this.length-1])`

		If `this` is the empty Array `[]`, the result is the empty String `""`.
		If `this` has exactly one element, the result is equal to a call to
		`Std.string(this[0])`.

		If `sep` is null, the result is unspecified.
	**/
	@:nativeFunctionCode("table.concat({this}, {arg0})")
	@:pure function join(sep:String):String;

	/**
		Removes the last element of `this` Array and returns it.

		This operation modifies `this` Array in place.

		If `this` has at least one element, `this.length` will decrease by 1.

		If `this` is the empty Array `[]`, null is returned and the length
		remains 0.
	**/
	@:nativeFunctionCode("table.remove({this}, #{this})")
	function pop():Null<T>;

	/**
		Adds the element `x` at the end of `this` Array and returns the new
		length of `this` Array.

		This operation modifies `this` Array in place.

		`this.length` increases by 1.
	**/
	inline function push(x:T):Int
	{
		this[this.length] = x;
		return this.length;
	}

	/**
		Reverse the order of elements of `this` Array.

		This operation modifies `this` Array in place.

		If `this.length < 2`, `this` remains unchanged.
	**/
	inline function reverse():Void
		ArrayTools.reverse(this);

	/**
		Removes the first element of `this` Array and returns it.

		This operation modifies `this` Array in place.

		If `this` has at least one element, `this`.length and the index of each
		remaining element is decreased by 1.

		If `this` is the empty Array `[]`, `null` is returned and the length
		remains 0.
	**/
	@:nativeFunctionCode("table.remove({this}, 1)")
	function shift():Null<T>;

	/**
		Creates a shallow copy of the range of `this` Array, starting at and
		including `pos`, up to but not including `end`.

		This operation does not modify `this` Array.

		The elements are not copied and retain their identity.

		If `end` is omitted or exceeds `this.length`, it defaults to the end of
		`this` Array.

		If `pos` or `end` are negative, their offsets are calculated from the
		end of `this` Array by `this.length + pos` and `this.length + end`
		respectively. If this yields a negative value, 0 is used instead.

		If `pos` exceeds `this.length` or if `end` is less than or equals
		`pos`, the result is `[]`.
	**/
	@:pure inline function slice(pos:Int, ?_end:Int):Array<T>
		return ArrayTools.slice(this, pos, _end);

	/**
		Sorts `this` Array according to the comparison function `f`, where
		`f(x,y)` returns 0 if x == y, a positive Int if x > y and a
		negative Int if x < y.

		This operation modifies `this` Array in place.

		The sort operation is not guaranteed to be stable, which means that the
		order of equal elements may not be retained. For a stable Array sorting
		algorithm, `haxe.ds.ArraySort.sort()` can be used instead.

		If `f` is null, the result is unspecified.
	**/
	inline function sort(f:T->T->Int):Void
	{
		var i = 0;
		var l = this.length;
		while (i < l)
		{
			var swap = false;
			var j = 0;
			var max = l - i - 1;
			while (j < max)
			{
				if (f(this[j], this[j + 1]) > 0)
				{
					var tmp = this[j + 1];
					this[j + 1] = this[j];
					this[j] = tmp;
					swap = true;
				}
				j += 1;
			}
			if (!swap)
				break;
			i += 1;
		}
	}

	/**
		Removes `len` elements from `this` Array, starting at and including
		`pos`, an returns them.

		This operation modifies `this` Array in place.

		If `len` is < 0 or `pos` exceeds `this`.length, an empty Array [] is
		returned and `this` Array is unchanged.

		If `pos` is negative, its value is calculated from the end	of `this`
		Array by `this.length + pos`. If this yields a negative value, 0 is
		used instead.

		If the sum of the resulting values for `len` and `pos` exceed
		`this.length`, this operation will affect the elements from `pos` to the
		end of `this` Array.

		The length of the returned Array is equal to the new length of `this`
		Array subtracted from the original length of `this` Array. In other
		words, each element of the original `this` Array either remains in
		`this` Array or becomes an element of the returned Array.
	**/
	inline function splice(pos:Int, len:Int):Array<T>
		return ArrayTools.splice(this, pos, len);

	/**
		Returns a string representation of `this` Array.

		The result will include the individual elements' String representations
		separated by comma. The enclosing [ ] may be missing on some platforms,
		use `Std.string()` to get a String representation that is consistent
		across platforms.
	**/
	@:nativeFunctionCode("('['..table.concat({this}, ',')..']')")
	@:pure function toString():String;

	/**
		Adds the element `x` at the start of `this` Array.

		This operation modifies `this` Array in place.

		`this.length` and the index of each Array element increases by 1.
	**/
	@:nativeFunctionCode("table.insert({this}, 1, {arg0})")
	function unshift(x:T):Void;

	/**
		Inserts the element `x` at the position `pos`.

		This operation modifies `this` Array in place.

		The offset is calculated like so:

		- If `pos` exceeds `this.length`, the offset is `this.length`.
		- If `pos` is negative, the offset is calculated from the end of `this`
		  Array, i.e. `this.length + pos`. If this yields a negative value, the
		  offset is 0.
		- Otherwise, the offset is `pos`.

		If the resulting offset does not exceed `this.length`, all elements from
		and including that offset to the end of `this` Array are moved one index
		ahead.
	**/
	@:nativeFunctionCode("table.insert({this}, {arg0}+1, {arg1})")
	function insert(pos:Int, x:T):Void;

	/**
		Removes the first occurrence of `x` in `this` Array.

		This operation modifies `this` Array in place.

		If `x` is found by checking standard equality, it is removed from `this`
		Array and all following elements are reindexed accordingly. The function
		then returns true.

		If `x` is not found, `this` Array is not changed and the function
		returns false.
	**/
	inline function remove(x:T):Bool
		return ArrayTools.safeRemove(this, x);

	/**
		Returns whether `this` Array contains `x`.

		If `x` is found by checking standard equality, the function returns `true`, otherwise
		the function returns `false`.
	**/
	@:pure inline function contains(x:T):Bool
		return ArrayTools.find(this, x) != null;

	/**
		Returns position of the first occurrence of `x` in `this` Array, searching front to back.

		If `x` is found by checking standard equality, the function returns its index.

		If `x` is not found, the function returns -1.

		If `fromIndex` is specified, it will be used as the starting index to search from,
		otherwise search starts with zero index. If it is negative, it will be taken as the
		offset from the end of `this` Array to compute the starting index. If given or computed
		starting index is less than 0, the whole array will be searched, if it is greater than
		or equal to the length of `this` Array, the function returns -1.
	**/
	@:pure inline function indexOf(x:T, ?fromIndex:Int):Int
		return ArrayTools.find(this, x, fromIndex) ?? -1;

	/**
		Returns position of the last occurrence of `x` in `this` Array, searching back to front.

		If `x` is found by checking standard equality, the function returns its index.

		If `x` is not found, the function returns -1.

		If `fromIndex` is specified, it will be used as the starting index to search from,
		otherwise search starts with the last element index. If it is negative, it will be
		taken as the offset from the end of `this` Array to compute the starting index. If
		given or computed starting index is greater than or equal to the length of `this` Array,
		the whole array will be searched, if it is less than 0, the function returns -1.
	**/
	@:pure inline function lastIndexOf(x:T, ?fromIndex:Int):Int
		return ArrayTools.rfind(this, x, fromIndex) ?? -1;

	/**
		Returns a shallow copy of `this` Array.

		The elements are not copied and retain their identity, so
		`a[i] == a.copy()[i]` is true for any valid `i`. However,
		`a == a.copy()` is always false.
	**/
	@:pure inline function copy():Array<T>
		return ArrayTools.copy(this);

	/**
		Returns an iterator of the Array values.
	**/
	public inline function iterator():ArrayIterator<T>
		return new ArrayIterator(this);

	/**
		Returns an iterator of the Array indices and values.
	**/
	public inline function keyValueIterator():ArrayKeyValueIterator<T>
		return new ArrayKeyValueIterator(this);

	/**
		Creates a new Array by applying function `f` to all elements of `this`.

		The order of elements is preserved.

		If `f` is null, the result is unspecified.
	**/
	inline function map<S>(f:T->S):Array<S>
		return ArrayTools.map(this, f);

	/**
		Returns an Array containing those elements of `this` for which `f`
		returned true.

		The individual elements are not duplicated and retain their identity.

		If `f` is null, the result is unspecified.
	**/
	inline function filter(f:T->Bool):Array<T>
		return ArrayTools.filter(this, f);

	/**
		Set the length of the Array.

		If `len` is shorter than the array's current size, the last
		`length - len` elements will be removed. If `len` is longer, the Array
		will be extended, with new elements set to a target-specific default
		value:

		- always null on dynamic targets
		- 0, 0.0 or false for Int, Float and Bool respectively on static targets
		- null for other types on static targets
	**/
	inline function resize(len:Int):Void
		ArrayTools.resize(this, len);
}
