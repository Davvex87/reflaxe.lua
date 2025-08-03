package rluacompiler.subcompilers;

#if (macro || rlua_runtime)

import haxe.macro.Type;

// Import Reflaxe types
import reflaxe.DirectToStringCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;
import Lambda;

class Classes extends SubCompiler {

	public function compileClassImpl(classType: ClassType, varFields: Array<ClassVarData>, funcFields: Array<ClassFuncData>): Null<String>
	{
		if (varFields.length == 0 && funcFields.length == 0)
			return null;

		var output = "";
		var superClassName:Null<String> = classType.superClass?.t?.get()?.name;

		output += 'local ${classType.name} = setmetatable({}, {\n\t__tostring = function(self)\n\t\treturn "Class<${classType.name}>"\n\tend;\n';

		if (superClassName != null)
			output += '\t__index = $superClassName;\n';

		output += '})\n';
		output += '${classType.name}.__index = ${classType.name}\n';

		if (superClassName != null)
			output += '${classType.name}.super = ${superClassName}\n';

		var hasInstField = Lambda.exists(varFields, v -> !v.isStatic) || Lambda.exists(funcFields, v -> !v.isStatic);

		for (varf in varFields)
		{
			if (varf.isStatic)
				output += main.fieldsSubCompiler.compileStaticImpl(varf);
		}

		if (hasInstField)
		{
			output += 'function ${classType.name}.new(...)\n';
			output += '\tlocal self = setmetatable({__tostring = function(self) return "${classType.name}" end}, ${classType.name})\n\tself:__constructor(...)\n\treturn self\n';
			output += 'end\n';
		}

		for (func in funcFields)
		{
			var r = main.fieldsSubCompiler.compileFuncImpl(func);
			if (r != null)
				output += r;
		}

		return output;
	}
}

#end