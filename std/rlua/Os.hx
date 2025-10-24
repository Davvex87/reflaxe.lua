package rlua;

import haxe.extern.EitherType;

/**
	Operating System Facilities.
**/
@:native("os")
extern class Os
{
	/**
	 * Returns an approximation of the amount in seconds of CPU time used by the program.
	 */
	static function clock():Float;

	/**
	 * Returns a string or a table containing date and time, formatted according to the given string format.
	 * 
	 * If the time argument is present, this is the time to be formatted (see the os.time function for a description of this value). Otherwise, date formats the current time.
	 * 
	 * If format starts with '!', then the date is formatted in Coordinated Universal Time. After this optional character, if format is the string "*t", then date returns a table with the following fields: year (four digits), month (1--12), day (1--31), hour (0--23), min (0--59), sec (0--61), wday (weekday, Sunday is 1), yday (day of the year), and isdst (daylight saving flag, a boolean).
	 * 
	 * If format is not "*t", then date returns the date as a string, formatted according to the same rules as the C function strftime.
	 * 
	 * When called without arguments, date returns a reasonable date and time representation that depends on the host system and on the current locale (that is, os.date() is equivalent to os.date("%c")).
	 */
	@:overload(function(format:String, time:Float):EitherType<String, DateResult> {})
	@:overload(function(format:String):EitherType<String, DateResult> {})
	static function date():String;

	/**
	 * Returns the number of seconds from time t1 to time t2. In POSIX, Windows, and some other systems, this value is exactly t2-t1.
	 */
	static function difftime(t2:Float, t1:Float):Float;

	/**
	 * This function is equivalent to the C function system. It passes command to be executed by an operating system shell. It returns a status code, which is system-dependent. If command is absent, then it returns nonzero if a shell is available and zero otherwise.
	 */
	static function execute(command:String):Int;

	/**
	 * Calls the C function exit, with an optional code, to terminate the host program. The default value for code is the success code.
	 */
	static function exit(?code:Int):Void;

	/**
	 * Returns the value of the process environment variable varname, or nil if the variable is not defined.
	 */
	static function getenv(varname:String):Null<String>;

	/**
	 * Deletes the file or directory with the given name. Directories must be empty to be removed. If this function fails, it returns nil, plus a string describing the error.
	 */
	static function remove(filename:String):RemoveResult;

	/**
	 * Renames file or directory named oldname to newname. If this function fails, it returns nil, plus a string describing the error.
	 */
	static function rename(oldname:String, newname:String):RenameResult;

	/**
	 * Sets the current locale of the program. locale is a string specifying a locale; category is an optional string describing which category to change: "all", "collate", "ctype", "monetary", "numeric", or "time"; the default category is "all". The function returns the name of the new locale, or nil if the request cannot be honored.
	 * 
	 * If locale is the empty string, the current locale is set to an implementation-defined native locale. If locale is the string "C", the current locale is set to the standard C locale.
	 * 
	 * When called with nil as the first argument, this function only returns the name of the current locale for the given category.
	 */
	static function setlocale(locale:String, ?category:String):Null<String>;

	/**
	 * Returns the current time when called without arguments, or a time representing the date and time specified by the given table. This table must have fields year, month, and day, and may have fields hour, min, sec, and isdst (for a description of these fields, see the os.date function).
	 * 
	 * The returned value is a number, whose meaning depends on your system. In POSIX, Windows, and some other systems, this number counts the number of seconds since some given start time (the "epoch"). In other systems, the meaning is not specified, and the number returned by time can be used only as an argument to date and difftime.
	 */
	static function time(?table:TimeParam):Float;

	/**
	 * Returns a string with a file name that can be used for a temporary file. The file must be explicitly opened before its use and explicitly removed when no longer needed.
	 * 
	 * On some systems (POSIX), this function also creates a file with that name, to avoid security risks. (Someone else might create the file with wrong permissions in the time between getting the name and creating the file.) You still have to open the file to use it and to remove it (even if you do not use it).
	 * 
	 * When possible, you may prefer to use io.tmpfile, which automatically removes the file when the program ends.
	 */
	static function tmpname():String;
}

typedef TimeParam =
{
	year:Int,
	month:Int,
	day:Int,
	?hour:Int,
	?min:Int,
	?sec:Int,
	?isdst:Bool
}

typedef DateResult =
{
	var hour:Int;
	var min:Int;
	var wday:Int;
	var day:Int;
	var month:Int;
	var year:Int;
	var sec:Int;
	var yday:Int;
	var isdst:Bool;
}

@:multiReturn
extern class RemoveResult
{
	var result:Dynamic;
	var error:String;
	var code:Int;
}

@:multiReturn
extern class RenameResult
{
	var result:Dynamic;
	var error:String;
	var code:Int;
}
