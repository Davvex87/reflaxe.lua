/**
	This class provides access to various base functions of system platforms.
	Look in the `sys` package for more system APIs.
**/

import rlua.Lua;
import sys.io.FileOutput;
import sys.io.FileInput;
import haxe.io.Path;
import rlua.FileHandle;
import rlua.Io;
import rlua.Os;
import rlua.Package;

class Sys
{
	private static final _args:Array<String> = untyped arg;

	/**
		Prints any value to the standard output.
	**/
	public static inline function print(v:Dynamic):Void
	{
		Io.write(Std.string(v));
		Io.flush();
	}

	/**
		Prints any value to the standard output, followed by a newline.
		On Windows, this function outputs a CRLF newline.
		LF newlines are printed on all other platforms.
	**/
	public static inline function println(v:Dynamic):Void
		rlua.Lua.print(v);

	/**
		Returns all the arguments that were passed in the command line.
		This does not include the interpreter or the name of the program file.

		(java)(eval) On Windows, non-ASCII Unicode arguments will not work correctly.

		(cs) Non-ASCII Unicode arguments will not work correctly.
	**/
	public static inline function args():Array<String>
		return _args;

	/**
		Returns the value of the given environment variable, or `null` if it
		doesn't exist.
	**/
	public static inline function getEnv(s:String):String
		return Os.getenv(s);

	/**
		Sets the value of the given environment variable.

		If `v` is `null`, the environment variable is removed.

		(java) This functionality is not available on Java; calling this function will throw.
	**/
	public static inline function putEnv(s:String, v:Null<String>):Void
	{
		if (_windowsSys)
			Os.execute('set $s=$v');
		else
			Os.execute('export $s=$v');
	}

	/**
		Returns a map of the current environment variables and their values
		as of the invocation of the function.

		(python) On Windows, the variable names are always in upper case.

		(cpp)(hl)(neko) On Windows, the variable names match the last capitalization used when modifying
		the variable if the variable has been modified, otherwise they match their capitalization at
		the start of the process.

		On Windows on remaining targets, variable name capitalization matches however they were capitalized
		at the start of the process or at the moment of their creation.
	**/
	public static function environment():Map<String, String>
	{
		var env:Map<String, String> = new Map();
		if (_windowsSys)
		{
			var p = Io.popen("set");
			for (line in p.lines())
			{
				untyped __lua__('local k, v = line.match("([^=]+)=(.*)")');
				untyped env[untyped k] = v;
			}
			p.close();
		}
		else
		{
			var p = Io.popen("printenv");
			for (line in p.lines())
			{
				untyped __lua__('local k, v = line.match("([^=]+)=(.*)")');
				untyped env[untyped k] = v;
			}
			p.close();
		}
		return env;
	}

	/**
		Suspends execution for the given length of time (in seconds).
	**/
	// TODO: Prefer using luvit or another lib for yielding functions when available
	public static function sleep(seconds:Float):Void
	{
		if (_windowsSys)
			Os.execute('ping -n ${seconds + 1} localhost >nul');
		else
			Os.execute('sleep $seconds');
	}

	/**
		Changes the current time locale, which will affect `DateTools.format` date formating.
		Returns `true` if the locale was successfully changed.
	**/
	public static function setTimeLocale(loc:String):Bool
		return Os.setlocale(loc) != null;

	/**
		Gets the current working directory (usually the one in which the program was started).
	**/
	public static function getCwd():String
	{
		var p = pcall(Io.popen, _windowsSys ? "echo \"$PWD\"" : "echo %cd%");
		if (p.success)
			return Path.addTrailingSlash(cast(p.value, FileHandle).read());

		return "/";
	}

	/**
		Changes the current working directory.

		If luvit is disabled, this function won't do anything.
	**/
	public static function setCwd(s:String):Void {}

	/**
		Returns the type of the current system. Possible values are:
		 - `"Windows"`
		 - `"Linux"`
		 - `"BSD"`
		 - `"Mac"`
	**/
	public static function systemName():String
	{
		if (_sysName == null)
		{
			if (_windowsSys)
				_sysName = "Windows";
			else
			{
				var p = pcall(Io.popen, "uname -s", "r");
				if (p.success)
					_sysName = cast(p.value, FileHandle).read("*l");
				else
					_sysName = "Unknown";
			}
		}
		return _sysName;
	}

	private static var _sysName:Null<String> = null;

	/**
		Runs the given command. The command output will be printed to the same output as the current process.
		The current process will block until the command terminates.
		The return value is the exit code of the command (usually `0` indicates no error).

		Command arguments can be passed in two ways:

		 1. Using `args` to pass command arguments. Each argument will be automatically quoted and shell meta-characters will be escaped if needed.
		`cmd` should be an executable name that can be located in the `PATH` environment variable, or a full path to an executable.

		 2. When `args` is not given or is `null`, command arguments can be appended to `cmd`. No automatic quoting/escaping will be performed. `cmd` should be formatted exactly as it would be when typed at the command line.
		It can run executables, as well as shell commands that are not executables (e.g. on Windows: `dir`, `cd`, `echo` etc).

		Use the `sys.io.Process` API for more complex tasks, such as background processes, or providing input to the command.
	**/
	public static inline function command(cmd:String, ?args:Array<String>):Int
	{
		return Os.execute(cmd + args.map(f -> escapeArg(f)).join(" "));
	}

	/**
		Exits the current process with the given exit code.
	**/
	public static inline function exit(code:Int):Void
		Os.exit(code);

	/**
		Gives the most precise timestamp value available (in seconds).
	**/
	public static inline function time():Float
		return Os.time();

	/**
		Gives the most precise timestamp value available (in seconds),
		but only accounts for the actual time spent running on the CPU for the current thread/process.
	**/
	public static inline function cpuTime():Float
		return Os.clock();

	/**
		Returns the path to the current executable that we are running.
	**/
	@:deprecated("Use programPath instead") public static inline function executablePath():String
		return programPath();

	/**
		Returns the absolute path to the current program file that we are running.
		Concretely, for an executable binary, it returns the path to the binary.
		For a script (e.g. a PHP file), it returns the path to the script.
	**/
	public static function programPath():String
		return haxe.io.Path.join([getCwd(), _args[0]]);

	/**
		Reads a single input character from the standard input and returns it.
		Setting `echo` to `true` will also display the character on the output.
	**/
	public static inline function getChar(echo:Bool):Int
		return Io.read().charCodeAt(0);

	/**
		Returns the standard input of the process, from which user input can be read.
		Usually it will block until the user sends a full input line.
		See `getChar` for an alternative.
	**/
	public static inline function stdin():haxe.io.Input
		return @:privateAccess new FileInput(Io.stdin);

	/**
		Returns the standard output of the process, to which program output can be written.
	**/
	public static inline function stdout():haxe.io.Output
		return @:privateAccess new FileOutput(Io.stdout);

	/**
		Returns the standard error of the process, to which program errors can be written.
	**/
	public static inline function stderr():haxe.io.Output
		return @:privateAccess new FileOutput(Io.stderr);

	private static var _windowsSys:Bool = Package.config.substr(0, 1) == "\\";

	private static function escapeArg(arg:String):String
	{
		if (_windowsSys)
		{
			if (arg.indexOf(" ") >= 0 || arg.indexOf("\t") >= 0 || arg.indexOf("\"") >= 0)
			{
				var escaped = new StringBuf();
				escaped.add("\"");
				var backslashes = 0;
				for (i in 0...arg.length)
				{
					var c = arg.charAt(i);
					if (c == "\\")
						backslashes++;
					else if (c == "\"")
					{
						escaped.add(StringTools.rpad("", "\\", backslashes * 2 + 1));
						escaped.add("\"");
						backslashes = 0;
					}
					else
					{
						if (backslashes > 0)
						{
							escaped.add(StringTools.rpad("", "\\", backslashes));
							backslashes = 0;
						}
						escaped.add(c);
					}
				}
				if (backslashes > 0)
					escaped.add(StringTools.rpad("", "\\", backslashes * 2));
				escaped.add("\"");
				return escaped.toString();
			}
			else
				return arg;
		}
		else
		{
			if (arg.indexOf("'") >= 0)
				return "'" + arg.split("'").join("'\\''") + "'";
			else
				return "'" + arg + "'";
		}
	}
}
