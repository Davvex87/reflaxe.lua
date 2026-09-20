package tests.unit.suites;

import shared.*;

@:keep
@:rtti
class TestStrings
{
	static final helloWorld = "Hello, World!";
	static final emptyString = "";
	static final singleChar = "A";
	static final multiWord = "The quick brown fox jumps over the lazy dog";
	static final withSpaces = "  leading and trailing  ";
	static final mixedCase = "HeLLo WoRLd";

	// Basic string properties

	@test
	static function testProperties()
	{
		Assert.equals(helloWorld, "Hello, World!");
		Assert.equals(helloWorld.length, 13);
		Assert.equals(emptyString.length, 0);
		Assert.equals(singleChar.length, 1);
	}

	// charAt tests

	@test
	static function testCharAt()
	{
		Assert.equals(helloWorld.charAt(0), "H");
		Assert.equals(helloWorld.charAt(1), "e");
		Assert.equals(helloWorld.charAt(4), "o");
		Assert.equals(helloWorld.charAt(12), "!");
		Assert.equals(helloWorld.charAt(-1), "");
		Assert.equals(helloWorld.charAt(13), "");
		Assert.equals(helloWorld.charAt(100), "");
		Assert.equals(emptyString.charAt(0), "");
	}

	// charCodeAt tests

	@test
	static function testCharCodeAt()
	{
		Assert.equals(helloWorld.charCodeAt(0), 72); // 'H'
		Assert.equals(helloWorld.charCodeAt(1), 101); // 'e'
		Assert.equals(helloWorld.charCodeAt(4), 111); // 'o'
		Assert.equals(helloWorld.charCodeAt(12), 33); // '!'
		Assert.equals(helloWorld.charCodeAt(-1), null);
		Assert.equals(helloWorld.charCodeAt(13), null);
		Assert.equals(helloWorld.charCodeAt(100), null);
		Assert.equals(emptyString.charCodeAt(0), null);
	}

	// indexOf tests

	@test
	static function testIndexOf()
	{
		Assert.equals(helloWorld.indexOf("Hello"), 0);
		Assert.equals(helloWorld.indexOf("World"), 7);
		Assert.equals(helloWorld.indexOf("o"), 4);
		Assert.equals(helloWorld.indexOf("o", 5), 8);
		Assert.equals(helloWorld.indexOf("l"), 2);
		Assert.equals(helloWorld.indexOf("l", 3), 3);
		Assert.equals(helloWorld.indexOf("l", 4), 10);
		Assert.equals(helloWorld.indexOf("xyz"), -1);
		Assert.equals(helloWorld.indexOf(""), 0);
		Assert.equals(helloWorld.indexOf("Hello", 1), -1);
		Assert.equals(helloWorld.indexOf("World", 14), -1);
		Assert.equals(helloWorld.indexOf("World", 100), -1);
		Assert.equals(emptyString.indexOf(""), 0);
		Assert.equals(emptyString.indexOf("a"), -1);
	}

	// lastIndexOf tests

	@test
	static function testLastIndexOf()
	{
		Assert.equals(helloWorld.lastIndexOf("Hello"), 0);
		Assert.equals(helloWorld.lastIndexOf("World"), 7);
		Assert.equals(helloWorld.lastIndexOf("o"), 8);
		Assert.equals(helloWorld.lastIndexOf("o", 7), 4);
		Assert.equals(helloWorld.lastIndexOf("l"), 10);
		Assert.equals(helloWorld.lastIndexOf("l", 9), 3);
		Assert.equals(helloWorld.lastIndexOf("l", 2), 2);
		Assert.equals(helloWorld.lastIndexOf("xyz"), -1);
		Assert.equals(helloWorld.lastIndexOf(""), 13);
		Assert.equals(helloWorld.lastIndexOf("World", 6), -1);
		Assert.equals(emptyString.lastIndexOf(""), 0);
		Assert.equals(emptyString.lastIndexOf("a"), -1);
	}

	// split tests

	@test
	static function testSplits()
	{
		final splitComma = helloWorld.split(",");
		Assert.equals(splitComma.length, 2);
		Assert.equals(splitComma[0], "Hello");
		Assert.equals(splitComma[1], " World!");

		final splitSpace = multiWord.split(" ");
		Assert.equals(splitSpace.length, 9);
		Assert.equals(splitSpace[0], "The");
		Assert.equals(splitSpace[8], "dog");

		final splitEmpty = helloWorld.split("");
		Assert.equals(splitEmpty.length, 13);
		Assert.equals(splitEmpty[0], "H");
		Assert.equals(splitEmpty[12], "!");

		final splitNotFound = helloWorld.split("xyz");
		Assert.equals(splitNotFound.length, 1);
		Assert.equals(splitNotFound[0], helloWorld);

		final splitEmptyString = emptyString.split(",");
		Assert.equals(splitEmptyString.length, 1);
		Assert.equals(splitEmptyString[0], "");
	}

	// substr tests

	@test
	static function testSubstr()
	{
		Assert.equals(helloWorld.substr(0), "Hello, World!");
		Assert.equals(helloWorld.substr(0, 5), "Hello");
		Assert.equals(helloWorld.substr(7, 5), "World");
		Assert.equals(helloWorld.substr(5), ", World!");
		Assert.equals(helloWorld.substr(-1), "!");
		Assert.equals(helloWorld.substr(-6), "World!");
		Assert.equals(helloWorld.substr(0, 20), "Hello, World!");
		Assert.equals(helloWorld.substr(10, 10), "ld!");
		Assert.equals(emptyString.substr(0), "");
		Assert.equals(emptyString.substr(0, 5), "");
	}

	// substring tests

	@test
	static function testSubstring()
	{
		Assert.equals(helloWorld.substring(0), "Hello, World!");
		Assert.equals(helloWorld.substring(0, 5), "Hello");
		Assert.equals(helloWorld.substring(7, 12), "World");
		Assert.equals(helloWorld.substring(5), ", World!");
		Assert.equals(helloWorld.substring(12, 7), "World");
		Assert.equals(helloWorld.substring(-3, 3), "Hel");
		Assert.equals(helloWorld.substring(0, 20), "Hello, World!");
		Assert.equals(helloWorld.substring(10, 10), "");
		Assert.equals(helloWorld.substring(13, 13), "");
		Assert.equals(emptyString.substring(0), "");
		Assert.equals(emptyString.substring(0, 5), "");
	}

	// toLowerCase tests

	@test
	static function testToLowerCase()
	{
		Assert.equals(helloWorld.toLowerCase(), "hello, world!");
		Assert.equals(mixedCase.toLowerCase(), "hello world");
		Assert.equals(singleChar.toLowerCase(), "a");
		Assert.equals(emptyString.toLowerCase(), "");
	}

	// toUpperCase tests

	@test
	static function testUpperCase()
	{
		Assert.equals(helloWorld.toUpperCase(), "HELLO, WORLD!");
		Assert.equals(mixedCase.toUpperCase(), "HELLO WORLD");
		Assert.equals(singleChar.toUpperCase(), "A");
		Assert.equals(emptyString.toUpperCase(), "");
	}

	// toString tests

	@test
	static function testToString()
	{
		Assert.equals(helloWorld.toString(), "Hello, World!");
		Assert.equals(emptyString.toString(), "");
	}

	// fromCharCode tests

	@test
	static function testFromCharCode()
	{
		Assert.equals(String.fromCharCode(65), "A");
		Assert.equals(String.fromCharCode(97), "a");
		Assert.equals(String.fromCharCode(32), " ");
		Assert.equals(String.fromCharCode(33), "!");
	}
	/*
		// StringTools tests (using static methods)
		Assert.equals(StringTools.contains(helloWorld, "Hello"), true);
		Assert.equals(StringTools.contains(helloWorld, "World"), true);
		Assert.equals(StringTools.contains(helloWorld, "xyz"), false);
		Assert.equals(StringTools.contains(helloWorld, ""), true);
		Assert.equals(StringTools.contains(emptyString, ""), true);
		Assert.equals(StringTools.contains(emptyString, "a"), false);

		Assert.equals(StringTools.startsWith(helloWorld, "Hello"), true);
		Assert.equals(StringTools.startsWith(helloWorld, "World"), false);
		Assert.equals(StringTools.startsWith(helloWorld, ""), true);
		Assert.equals(StringTools.startsWith(emptyString, ""), true);
		Assert.equals(StringTools.startsWith(emptyString, "a"), false);

		Assert.equals(StringTools.endsWith(helloWorld, "World!"), true);
		Assert.equals(StringTools.endsWith(helloWorld, "Hello"), false);
		Assert.equals(StringTools.endsWith(helloWorld, ""), true);
		Assert.equals(StringTools.endsWith(emptyString, ""), true);
		Assert.equals(StringTools.endsWith(emptyString, "a"), false);

		Assert.equals(StringTools.trim(withSpaces), "leading and trailing");
		Assert.equals(StringTools.trim("  test  "), "test");
		Assert.equals(StringTools.trim("test"), "test");
		Assert.equals(StringTools.trim(emptyString), "");
		Assert.equals(StringTools.trim("   "), "");

		Assert.equals(StringTools.ltrim(withSpaces), "leading and trailing  ");
		Assert.equals(StringTools.ltrim("  test  "), "test  ");
		Assert.equals(StringTools.ltrim("test"), "test");
		Assert.equals(StringTools.ltrim(emptyString), "");
		Assert.equals(StringTools.ltrim("   "), "");

		Assert.equals(StringTools.rtrim(withSpaces), "  leading and trailing");
		Assert.equals(StringTools.rtrim("  test  "), "  test");
		Assert.equals(StringTools.rtrim("test"), "test");
		Assert.equals(StringTools.rtrim(emptyString), "");
		Assert.equals(StringTools.rtrim("   "), "");

		Assert.equals(StringTools.replace(helloWorld, "World", "Haxe"), "Hello, Haxe!");
		Assert.equals(StringTools.replace(helloWorld, "l", "L"), "HeLLo, WorLd!");
		Assert.equals(StringTools.replace(helloWorld, "xyz", "abc"), "Hello, World!");
		Assert.equals(StringTools.replace(helloWorld, "", "-"), "H-e-l-l-o-,- -W-o-r-l-d-!");
		Assert.equals(StringTools.replace(emptyString, "a", "b"), "");

		Assert.equals(StringTools.lpad("test", "0", 8), "0000test");
		Assert.equals(StringTools.lpad("test", "x", 6), "xxtest");
		Assert.equals(StringTools.lpad("test", "ab", 8), "ababtest");
		Assert.equals(StringTools.lpad("test", "", 8), "test");
		Assert.equals(StringTools.lpad("test", "x", 3), "test");

		Assert.equals(StringTools.rpad("test", "0", 8), "test0000");
		Assert.equals(StringTools.rpad("test", "x", 6), "testxx");
		Assert.equals(StringTools.rpad("test", "ab", 8), "testabab");
		Assert.equals(StringTools.rpad("test", "", 8), "test");
		Assert.equals(StringTools.rpad("test", "x", 3), "test");

		Assert.equals(StringTools.htmlEscape("<div>test</div>"), "&lt;div&gt;test&lt;/div&gt;");
		Assert.equals(StringTools.htmlEscape('a "b" c'), 'a &quot;b&quot; c');
		Assert.equals(StringTools.htmlEscape("a 'b' c", true), "a &#039;b&#039; c");
		Assert.equals(StringTools.htmlEscape("a & b"), "a &amp; b");

		Assert.equals(StringTools.htmlUnescape("&lt;div&gt;test&lt;/div&gt;"), "<div>test</div>");
		Assert.equals(StringTools.htmlUnescape('a &quot;b&quot; c'), 'a "b" c');
		Assert.equals(StringTools.htmlUnescape("a &#039;b&#039; c"), "a 'b' c");
		Assert.equals(StringTools.htmlUnescape("a &amp; b"), "a & b");

		Assert.equals(StringTools.urlEncode("hello world"), "hello%20world");
		Assert.equals(StringTools.urlEncode("a+b=c"), "a%2Bb%3Dc");
		Assert.equals(StringTools.urlEncode("test"), "test");

		Assert.equals(StringTools.urlDecode("hello%20world"), "hello world");
		Assert.equals(StringTools.urlDecode("a%2Bb%3Dc"), "a+b=c");
		Assert.equals(StringTools.urlDecode("test"), "test");

		Assert.equals(StringTools.hex(255), "FF");
		Assert.equals(StringTools.hex(255, 4), "00FF");
		Assert.equals(StringTools.hex(15), "F");
		Assert.equals(StringTools.hex(15, 2), "0F");

		Assert.equals(StringTools.isSpace(" test", 0), true);
		Assert.equals(StringTools.isSpace("test", 0), false);
		Assert.equals(StringTools.isSpace("", 0), false);
		Assert.equals(StringTools.isSpace("test", -1), false);
		Assert.equals(StringTools.isSpace("test", 4), false);
	 */
}
