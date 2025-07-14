# Reflaxe/Lua

A compiler that compiles Haxe code into native Lua 5.1 without all of the bloat that the default Haxe compiler produces. It attempts to match Haxe's sources as closely as possible to their Lua implementations (arrays and objects get converted into tables, Int, Int64, Int32, Float and Double also just get converted to Lua's number type, etc...).

Made to be editable and extendable to other Lua versions/subsets (i.e. Lua 5.3, LuaJIT, Luau, Squirrel) with ease.
<br>
^^^ At the current state, not really, for now its mostly just a proof of concept, not a complete implementation :P

Pull requests and issues are welcome!

Powered by [Reflaxe](https://github.com/SomeRanDev/Reflaxe)