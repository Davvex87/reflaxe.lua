# LOOKING FOR CONTRIBUTORS

As the sole maintainer, implementing everything in the [Haxe Standard Library](https://github.com/HaxeFoundation/haxe/tree/4.3.7/std) is a significant, time consuming task. Contributions are welcome and appreciated.
<br>
If you're interested in helping the project, read the [Contributing](#contributing) section for more information on how you can support this project ⭐.
<br><br><br><br><br><br>
<a id="reflaxe.lua"></a>

<img src="img/reflaxe.lua banner.png" style="image-rendering: pixelated;" />

A compiler that compiles Haxe code into native Lua 5.1 without all of the bloat that the default Haxe compiler produces. It attempts to match Haxe's sources as closely as possible to their Lua implementations (arrays and objects get converted into tables, Int, Int64, Int32, Float and Double also just get converted to Lua's number type, etc...).

Made to be editable and extendable to other Lua versions/subsets (i.e. Lua 5.3, LuaJIT, Luau, Squirrel) with ease.

<p>
	Powered by
	<a href="https://github.com/SomeRanDev/Reflaxe">
		<img src="https://i.imgur.com/oZkCZ2C.png" alt="Reflaxe" width="80" style="vertical-align: middle;" />
	</a>
</p>

## Example

<div style="display: flex; gap: 10px;">
<div style="width: 50%; height: 100%;">
Haxe source input:

```haxe
class Main
{
	static function main()
	{
		var arr = [1, 2, 5];
		arr.push(8);
		trace(arr[2]); // 5
	}
}

// Most types will be converted to
// their native lua implementations
// whenever possible. Less bloat :D



```

</div>
<div style="width: 50%; height: 100%;">
Lua source output (simplified):

```lua
local Main = setmetatable({}, {
	__tostring = function(self)
		return "Class<Main>"
	end;
})
Main.__index = Main
function Main.main()
	local arr = {1, 2, 5}
	table.insert(arr, 8)
	Log.trace(arr[3], {
		fileName = "Code.hx",
		lineNumber = 300,
		className = "Main",
		methodName = "main"
	})
end
```
</div>
</div>

## Table of Contents
- [Introduction](#reflaxe.lua)
  - [Example](#example)
- [Progress](#progress)
- [Setup](#setup)
  - [Installing the library](#installing-the-library)
  - [Adding to project](#adding-to-project)
  - [Bind an output folder](#bind-an-output-folder)
  - [Configure as needed](#configure-as-needed)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

# Progress

### Code Generation Efficiency
How optimized the generated output is compared to naturally written Lua.

![75](https://progress-bar.xyz/75/?width=200)

Generation Problems:
- Unary operator overhead through unnecessary function calls
- OpAssignOp (+=, -=, &=, etc..) overhead through unnecessary function calls
- Blind objects (the compiler makes often heavy assumptions about objects)

### Lua API Coverage
How much of Lua's API is covered by Reflaxe.lua.

![80](https://progress-bar.xyz/80/?width=200)

Missing:
- table (native)
- string (native)

### Haxe Std Library Coverage
How complete are the Std Library's Lua bindings.

![60](https://progress-bar.xyz/60/?width=200)

Missing:
- net (requires external lib)
- EReg (somewhat broken)

### Haxe Primitives & Types
How many of Haxe's primitive and support types are implemented.

![70](https://progress-bar.xyz/70/?width=200)

Missing:
- Abstracts
- Abstract Classes

### Haxe Language Features Support
How many of Haxe's language features are correctly compiled to their Lua alternatives.

![80](https://progress-bar.xyz/80/?width=200)

- Getters/Setters (somewhat broken)

# Setup

<a id="installing-the-library"></a>

1. Installing Reflaxe:
  - ``haxelib install reflaxe 4.0.0-beta``

2. Installing the library:
  - haxelib: **haxelib install not yet available**
  - github: ``haxelib git reflaxe.lua https://github.com/Davvex87/reflaxe.lua.git``

<a id="adding-to-project"></a>

3. Adding to project:
  - hxml: ``-lib reflaxe.lua``

<a id="bind-an-output-folder"></a>

4. Bind an output folder:
```hxml
-D lua-output=out
```

<a id="configure-as-needed"></a>

5. Configure as needed:
```hxml
# Paste this script in your .hxml file and configure to suit your needs.
# To enable a configuration, uncomment by removing the "#" character before each -D flag.
# Flags which include an argument assignment (i.e. ``-D lua-safe=<no|soft|full>``) can be selected to have a mode.


# Bitwise operations will use the bit32 library when possible.
#-D lua-bit32


# String operations will use the utf8 library when possible.
#-D lua-utf8


# Inline log operations to the ``print`` function
#-D lua-inline-trace


# All type checking operations at runtime will do deep checks to ensure the correct result is always returned, at the cost of runtime performance.
#   ``no`` - Safe checking is off (default);
#   ``soft`` - Performs only fast checks (ideal);
#   ``full`` - Ensures that type checks return the correct value every time (safest, but heavy);
#-D lua-safe=<no|soft|full>
```

# Usage
All Haxe types present in the Haxe Standard Library can be used as usual.
Reflaxe.lua also provides it's own lua library for quick access to lua objects and methods, these operations can be found under the ``rlua`` package

# Troubleshooting
If you are having compile-time errors or run-time issues, please take a look at [TROUBLESHOOTING.md](TROUBLESHOOTING.md) before submitting an Issue.

# Contributing
If you're interested in helping the project, **feel free to open a pull request or submit an issue**. Please just make sure that the issue you're reporting has not been reported yet, same thing for pull requests.

Both Reflaxe.lua and [Reflaxe](https://github.com/SomeRanDev/Reflaxe) are community ran projects made for everyone and to suit everyone's needs. There's still a lot to implement and improve, every contribution helps a ton ❤️.
