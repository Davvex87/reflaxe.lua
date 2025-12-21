package;

import haxe.io.EReg;

class TestEReg
{
	public static function testBasicMatching()
	{
		trace("=== EReg Basic Matching Tests ===");
		
		var regex = ~/haxe/i;
		trace("haxe matches 'Haxe': " + regex.match("Haxe")); // should be true
		trace("matched: " + regex.matched(0)); // should be "Haxe"
		
		var digitRegex = ~/\d+/;
		trace("digit matches '123': " + digitRegex.match("abc123def")); // should be true
		trace("matched: " + digitRegex.matched(0)); // should be "123"
		trace("matchedLeft: " + digitRegex.matchedLeft()); // should be "abc"
		trace("matchedRight: " + digitRegex.matchedRight()); // should be "def"
		
		var pos = digitRegex.matchedPos();
		trace("matchedPos: pos=" + pos.pos + ", len=" + pos.len); // pos=3, len=3
	}
	
	public static function testReplace()
	{
		trace("=== EReg Replace Tests ===");
		
		var regex = ~/cat/g;
		var result = regex.replace("The cat sat on the catwalk", "dog");
		trace("Replace result: " + result); // "The dog sat on the dogwalk"
		
		var emailRegex = ~/(\w+)@(\w+\.\w+)/;
		var result2 = emailRegex.replace("Contact user@test.com for info", "[$1@$2]");
		trace("Email replace: " + result2); // "Contact [user@test.com] for info"
	}
	
	public static function testSplit()
	{
		trace("=== EReg Split Tests ===");
		
		var regex = ~/,\s*/;
		var parts = regex.split("apple, banana,  cherry ,date");
		trace("Split result: " + parts.toString()); // ["apple", "banana", "cherry", "date"]
		
		var wordRegex = ~/\s+/;
		var words = wordRegex.split("Hello   world  from   Haxe");
		trace("Word split: " + words.toString()); // ["Hello", "world", "from", "Haxe"]
	}
	
	public static function testEscape()
	{
		trace("=== EReg Escape Tests ===");
		
		var escaped = EReg.escape("a.b*c+d?e[f]g(h)i$j^k|l\\m");
		trace("Escaped: " + escaped); // Should escape all special chars
	}
	
	public static function runAllTests()
	{
		testBasicMatching();
		testReplace();
		testSplit();
		testEscape();
	}
}