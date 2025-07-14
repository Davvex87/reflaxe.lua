package rluacompiler.subcompilers;

#if (macro || rlua_runtime)

class SubCompiler
{
	var main:rluacompiler.Compiler;
    public function new(main:rluacompiler.Compiler)
	{
        this.main = main;
    }
}

#end