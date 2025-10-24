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

package haxe.io;

import rlua.Boot;

class Bytes
{
	public var length(default, null):Int;

	var b:BytesData;

	function new(length, b)
	{
		this.length = length;
		this.b = b;
	}

	/**
		Returns the byte at index `pos`.
	**/
	public inline function get(pos:Int):Int
	{
		return b[pos];
	}

	/**
		Stores the given byte `v` at the given position `pos`.
	**/
	public inline function set(pos:Int, v:Int):Void
	{
		b[pos] = v & 0xFF;
	}

	/**
		Copies `len` bytes from `src` into this instance.
		@param pos Zero-based location in `this` instance at which to start writing
			bytes.
		@param src Source `Bytes` instance from which to copy bytes.
		@param srcpos Zero-based location at `src` from which bytes will be copied.
		@param len Number of bytes to be copied.
	**/
	public function blit(pos:Int, src:Bytes, srcpos:Int, len:Int):Void
	{
		var b1 = b;
		var b2 = src.b;
		if (b1 == b2 && pos > srcpos)
		{
			var i = len;
			while (i > 0)
			{
				i--;
				b1[i + pos] = b2[i + srcpos];
			}
			return;
		}
		for (i in 0...len)
			b1[i + pos] = b2[i + srcpos];
	}

	/**
		Sets `len` consecutive bytes starting from index `pos` of `this` instance
		to `value`.
	**/
	public function fill(pos:Int, len:Int, value:Int)
	{
		for (i in 0...len)
			set(pos++, value);
	}

	/**
		Returns a new `Bytes` instance that contains a copy of `len` bytes of
		`this` instance, starting at index `pos`.
	**/
	public function sub(pos:Int, len:Int):Bytes
	{
		return new Bytes(len, b.slice(pos, pos + len));
	}

	/**
		Returns `0` if the bytes of `this` instance and the bytes of `other` are
		identical.

		Returns a negative value if the `length` of `this` instance is less than
		the `length` of `other`, or a positive value if the `length` of `this`
		instance is greater than the `length` of `other`.

		In case of equal `length`s, returns a negative value if the first different
		value in `other` is greater than the corresponding value in `this`
		instance; otherwise returns a positive value.
	**/
	public function compare(other:Bytes):Int
	{
		var b1 = b;
		var b2 = other.b;
		var len = (length < other.length) ? length : other.length;
		for (i in 0...len)
			if (b1[i] != b2[i])
				return untyped b1[i] - b2[i];
		return length - other.length;
	}

	/**
		Returns the IEEE double-precision value at the given position `pos` (in
		little-endian encoding). Result is unspecified if `pos` is outside the
		bounds.
	**/
	public function getDouble(pos:Int):Float
	{
		return FPHelper.i64ToDouble(getInt32(pos), getInt32(pos + 4));
	}

	/**
		Returns the IEEE single-precision value at the given position `pos` (in
		little-endian encoding). Result is unspecified if `pos` is outside the
		bounds.
	**/
	public function getFloat(pos:Int):Float
	{
		return FPHelper.i32ToFloat(getInt32(pos));
	}

	/**
		Stores the given IEEE double-precision value `v` at the given position
		`pos` in little-endian encoding. Result is unspecified if writing outside
		of bounds.
	**/
	public function setDouble(pos:Int, v:Float):Void
	{
		var i = FPHelper.doubleToI64(v);
		setInt32(pos, i.low);
		setInt32(pos + 4, i.high);
	}

	/**
		Stores the given IEEE single-precision value `v` at the given position
		`pos` in little-endian encoding. Result is unspecified if writing outside
		of bounds.
	**/
	public function setFloat(pos:Int, v:Float):Void
	{
		setInt32(pos, FPHelper.floatToI32(v));
	}

	/**
		Returns the 16-bit unsigned integer at the given position `pos` (in
		little-endian encoding).
	**/
	public inline function getUInt16(pos:Int):Int
	{
		return get(pos) | (get(pos + 1) << 8);
	}

	/**
		Stores the given 16-bit unsigned integer `v` at the given position `pos`
		(in little-endian encoding).
	**/
	public inline function setUInt16(pos:Int, v:Int):Void
	{
		set(pos, v);
		set(pos + 1, v >> 8);
	}

	/**
		Returns the 32-bit integer at the given position `pos` (in little-endian
		encoding).
	**/
	public inline function getInt32(pos:Int):Int
	{
		var v = get(pos) | (get(pos + 1) << 8) | (get(pos + 2) << 16) | (get(pos + 3) << 24);
		return Boot.clampInt32(if (v & 0x80000000 != 0) v | 0x80000000 else v);
	}

	/**
		Returns the 64-bit integer at the given position `pos` (in little-endian
		encoding).
	**/
	public inline function getInt64(pos:Int):haxe.Int64
	{
		return haxe.Int64.make(getInt32(pos + 4), getInt32(pos));
	}

	/**
		Stores the given 32-bit integer `v` at the given position `pos` (in
		little-endian encoding).
	**/
	public inline function setInt32(pos:Int, v:Int):Void
	{
		set(pos, v);
		set(pos + 1, v >> 8);
		set(pos + 2, v >> 16);
		set(pos + 3, v >>> 24);
	}

	/**
		Stores the given 64-bit integer `v` at the given position `pos` (in
		little-endian encoding).
	**/
	public inline function setInt64(pos:Int, v:haxe.Int64):Void
	{
		setInt32(pos, v.low);
		setInt32(pos + 4, v.high);
	}

	/**
		Returns the `len`-bytes long string stored at the given position `pos`,
		interpreted with the given `encoding` (UTF-8 by default).
	**/
	public function getString(pos:Int, len:Int, ?encoding:Encoding):String
	{
		if (b.length - pos <= Boot.MAXSTACKSIZE)
		{
			var end:Int = cast Math.min(b.length, pos + len) - 1;
			return untyped string.char(unpack(untyped b, pos, end));
		}
		else
		{
			var tbl:Array<String> = [];
			for (idx in pos...pos + len)
			{
				tbl.push(untyped string.char(b[idx]));
			}
			return untyped table.concat(tbl, '');
		}
	}

	@:deprecated("readString is deprecated, use getString instead")
	@:noCompletion
	public inline function readString(pos:Int, len:Int):String
	{
		return getString(pos, len);
	}

	/**
		Returns a `String` representation of the bytes interpreted as UTF-8.
	**/
	public function toString():String
	{
		return getString(0, length);
	}

	/**
		Returns a hexadecimal `String` representation of the bytes of `this`
		instance.
	**/
	public function toHex():String
	{
		var s = new StringBuf();
		var chars = [];
		var str = "0123456789abcdef";
		for (i in 0...str.length)
			chars.push(str.charCodeAt(i));
		for (i in 0...length)
		{
			var c = get(i);
			s.addChar(chars[c >> 4]);
			s.addChar(chars[c & 15]);
		}
		return s.toString();
	}

	/**
		Returns the bytes of `this` instance as `BytesData`.
	**/
	public inline function getData():BytesData
	{
		return b;
	}

	/**
		Returns a new `Bytes` instance with the given `length`. The values of the
		bytes are not initialized and may not be zero.
	**/
	public static function alloc(length:Int):Bytes
	{
		var a = new Array();
		for (i in 0...length)
			a.push(0);
		return new Bytes(length, a);
	}

	/**
		Returns the `Bytes` representation of the given `String`, using the
		specified encoding (UTF-8 by default).
	**/
	@:pure
	public static function ofString(s:String, ?encoding:Encoding):Bytes
	{
		var bytes = [
			for (i in 0...s.length)
			{
				untyped string.byte(s, i + 1);
			}
		];
		return new Bytes(bytes.length, bytes);
	}

	/**
		Returns the `Bytes` representation of the given `BytesData`.
	**/
	public static function ofData(b:BytesData)
	{
		return new Bytes(b.length, b);
	}

	/**
		Converts the given hexadecimal `String` to `Bytes`. `s` must be a string of
		even length consisting only of hexadecimal digits. For example:
		`"0FDA14058916052309"`.
	**/
	public static function ofHex(s:String):Bytes
	{
		var len:Int = s.length;
		if ((len & 1) != 0)
			throw "Not a hex string (odd number of digits)";
		var ret:Bytes = Bytes.alloc(len >> 1);
		for (i in 0...ret.length)
		{
			var high = StringTools.fastCodeAt(s, i * 2);
			var low = StringTools.fastCodeAt(s, i * 2 + 1);
			high = (high & 0xF) + ((high & 0x40) >> 6) * 9;
			low = (low & 0xF) + ((low & 0x40) >> 6) * 9;
			ret.set(i, ((high << 4) | low) & 0xFF);
		}

		return ret;
	}

	/**
		Reads the `pos`-th byte of the given `b` bytes, in the most efficient way
		possible. Behavior when reading outside of the available data is
		unspecified.
	**/
	public inline static function fastGet(b:BytesData, pos:Int):Int
	{
		return b[pos];
	}
}
