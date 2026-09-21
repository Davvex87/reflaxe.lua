package rluacompiler.utils;

#if (macro || rlua_runtime)
class LuaVUtils
{
	public static final bitClassPackage = "rlua.Bit";
	public static final bitFuncField:BitwiseOperatorsProxyOptions = {
		opAnd: "band",
		opOr: "bor",
		opXor: "bxor",
		opShl: "lshift",
		opShr: "arshift",
		opUShr: "rshift",
		opNegBits: "bnot"
	};
}

@:structInit
class BitwiseOperatorsProxyOptions
{
	/**
		`&`
	**/
	public var opAnd:String;

	/**
		`|`
	**/
	public var opOr:String;

	/**
		`^`
	**/
	public var opXor:String;

	/**
		`<<`
	**/
	public var opShl:String;

	/**
		`>>`
	**/
	public var opShr:String;

	/**
		`>>>`
	**/
	public var opUShr:String;

	/**
		`~`
	**/
	public var opNegBits:String;
}
#end
