package rlua;

@:native("io")
extern class Io
{
	static var stdin:FileHandle;
	static var stderr:FileHandle;
	static var stdout:FileHandle;

	/**
	 * Equivalent to file:close(). Without a file, closes the default output file.
	 */
	static function close(?file:FileHandle):Void;

	/**
	 * Equivalent to file:flush over the default output file.
	 */
	static function flush():Void;

	/**
	 * When called with a file name, it opens the named file (in text mode), and sets its handle as the default input file.
	 * When called with a file handle, it simply sets this file handle as the default input file.
	 * When called without parameters, it returns the current default input file.
	 * 
	 * In case of errors this function raises the error, instead of returning an error code.
	 */
	@:overload(function():Void {})
	@:overload(function(file:String):Void {})
	static function input(file:FileHandle):Void;

	/**
	 * Opens the given file name in read mode and returns an iterator function that, each time it is called,
	 * returns a new line from the file. Therefore, the construction
	 * ``for line in io.lines(filename) do body end``
	 * will iterate over all lines of the file.
	 * When the iterator function detects the end of file, it returns nil (to finish the loop) and automatically closes the file.
	 * 
	 * The call io.lines() (with no file name) is equivalent to io.input():lines();
	 * that is, it iterates over the lines of the default input file. In this case it does not close the file when the loop ends.
	 */
	static function lines(?filename:String):Iterator<String>;

	/**
	 * This function opens a file, in the mode specified in the string mode.
	 * It returns a new file handle, or, in case of errors, nil plus an error message.
	 * 
	 * The mode string can be any of the following:
	 * 
	 * `"r"`: read mode (the default);
	 * `"w"`: write mode;
	 * `"a"`: append mode;
	 * `"r+"`: update mode, all previous data is preserved;
	 * `"w+"`: update mode, all previous data is erased;
	 * `"a+"`: append update mode, previous data is preserved, writing is only allowed at the end of file.
	 * The mode string can also have a 'b' at the end, which is needed in some systems to open the file in binary mode.
	 * This string is exactly what is used in the standard C function fopen.
	 */
	static function open(filename:String, ?mode:String):FileHandle;

	/**
	 * Similar to io.input, but operates over the default output file.
	 */
	static function output(?file:String):FileHandle;

	/**
	 * Starts program prog in a separated process and returns a file handle that you can use to read data from this program
	 * (if mode is "r", the default) or to write data to this program (if mode is "w").
	 * 
	 * This function is system dependent and is not available on all platforms.
	 */
	static function popen(prog:String, ?mode:String):FileHandle;

	/**
	 * Equivalent to io.input():read.
	 */
	static function read(?file:String):String;

	/**
	 * Returns a handle for a temporary file. This file is opened in update mode and it is automatically removed when
	 * the program ends.
	 */
	static function tmpfile():FileHandle;

	/**
	 * Checks whether obj is a valid file handle. Returns the string "file" if obj is an open file handle,
	 * "closed file" if obj is a closed file handle, or nil if obj is not a file handle.
	 */
	static function type(obj:FileHandle):IoType;

	/**
	 * Equivalent to io.output():write.
	 */
	static function write(...args:String):Void;
}

/**
	A enumerator that describes the output of `Io.type()`.
**/
enum abstract IoType(String)
{
	var File = "file";
	var ClosedFile = "closed file";
	var NotAFile = null;

	@:to public function toString()
	{
		return this;
	}
}
