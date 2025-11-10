# To-Do

- Custom require methods
- Compiler plugins support (to easily make language subsets)
- More compiler flags
- Implement static initialization
- Use a Lua AST instead of the DirectToStringCompiler

# Fixes

``src/rluacompiler/preprocessors/implementations/ConvertBitwiseOperators.hx:57``
``src/rluacompiler/preprocessors/implementations/ConvertBitwiseOperators.hx:77``
``src/rluacompiler/preprocessors/implementations/ConvertBitwiseOperators.hx:92``

\- Maybe use as TField instead of a TIdent here? Should play nicer with custom preprocessors.

<br>

``std/rlua/_std/StringTools.hx:159``

\- Review this to see if it works.

<br>

``std/rlua/_std/Sys.hx:112``

\- Prefer using luvit or another lib for yielding functions when available.

<br>

``std/rlua/_std/Type.hx:22``

\- This generates wrong lua code.

<br>

``std/rlua/_std/Type.hx:251``

\- Find a workaround for this since we don't have a native String class to use.

<br>

``std/rlua/Bit.hx:18``

\- This just supports the bit library, gotta add the functions from the bit32 as well.

<br>

``std/rlua/Runtime.hx:7``

\- Implement the lua-safe compiler def stuff here.

<br>



## Note
There may be some more notes and TODOs or FIXMEs around the source code that are not mentioned here. Feel free to pick up any of these and file a pull request with a solution!
