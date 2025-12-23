package rluacompiler.subcompilers;

#if (macro || rlua_runtime)
import reflaxe.DirectToStringCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;
import haxe.macro.Type;
import Lambda;

class Classes extends SubCompiler
{
	public function compileClassImpl(classType:ClassType, varFields:Array<ClassVarData>, funcFields:Array<ClassFuncData>):Null<String>
	{
		var output = "";
		var superClassName:Null<String> = classType.superClass?.t?.get()?.name;

		/*
			output += '${classType.name} = setmetatable({}, {\n\t__tostring = function(self)\n\t\treturn "Class<${classType.name}>"\n\tend;\n';
		 */
		output += 'setmetatable(${classType.name}, {\n\t__tostring = function(self)\n\t\treturn "Class<${classType.name}>"\n\tend;\n';

		if (superClassName != null)
			output += '\t__index = $superClassName;\n';

		output += '})\n';
		output += '${classType.name}.__index = ${classType.name}\n';

		output += '${classType.name}.__name__ = "${classType.name}"\n';

		if (superClassName != null)
			output += 'local __super__ = ${superClassName}\n';

		if (classType.interfaces.length > 0)
			output += '${classType.name}.__interfaces__ = {${classType.interfaces.map((i) -> i.t.get().name).join(", ")}}\n';

		var hasInstField = Lambda.exists(varFields, v -> !v.isStatic) || Lambda.exists(funcFields, v -> !v.isStatic);

		if (classType.isInterface)
		{
			var fields = varFields.map((i) -> !i.isStatic ? '"${i.field.name}"' : null)
				.concat(funcFields.map((i) -> !i.isStatic ? '"${i.field.name}"' : null))
				.filter((s) -> s != null);
			output += '${classType.name}.__interface__ = {${fields.join(", ")}}\n';
		}
		else
		{
			var statics = varFields.map((i) -> i.isStatic ? '"${i.field.name}"' : null)
				.concat(funcFields.map((i) -> i.isStatic ? '"${i.field.name}"' : null))
				.filter((s) -> s != null);
			var fields = varFields.map((i) -> !i.isStatic ? '"${i.field.name}"' : null)
				.concat(funcFields.map((i) -> !i.isStatic ? '"${i.field.name}"' : null))
				.filter((s) -> s != null);
			if (statics.length > 0)
				output += '${classType.name}.__fields__ = {${statics.join(", ")}}\n';
			if (fields.length > 0)
				output += '${classType.name}.__prototype__ = {${fields.join(", ")}}\n';

			var properties = varFields.map((i) -> i.getter != null ? i.getter.name : null)
				.concat(varFields.map((i) -> i.setter != null ? i.setter.name : null))
				.filter((s) -> s != null);
			if (properties.length > 0)
				output += '${classType.name}.__properties__ = {${properties.join(", ")}}\n';

			var inlinesStatics:Array<ClassVarData> = [];
			for (varf in varFields)
			{
				if (!varf.isStatic)
					continue;
				var expr = varf.field.expr();
				if (expr == null)
					continue;

				if (expr.expr.match(TBlock(_)))
					inlinesStatics.push(varf);
				else
					output += main.fieldsSubCompiler.compileStaticImpl(varf);
			}

			if (hasInstField)
			{
				output += 'function ${classType.name}.new(...)\n';
				output += '\tlocal self = setmetatable({}, {__index = ${classType.name}; __tostring = function(self) if self["toString"] ~= nil then return self:toString() end return "${classType.name}" end})\n\tself:__constructor(...)\n\treturn self\n';
				output += 'end\n';
			}

			for (func in funcFields)
			{
				var r = main.fieldsSubCompiler.compileFuncImpl(func);
				if (r != null)
					output += r;
			}

			if (inlinesStatics.length > 0)
			{
				output += "\ndo\n";
				for (varf in inlinesStatics)
				{
					var r = main.expressionsSubCompiler.compileExpressionImpl(varf.field.expr(), 0);
					if (r != null)
						output += '\t' + StringTools.replace(r, "\n", "\n\t") + '\n';
				}
				output += 'end\n';
			}
		}

		return output;
	}
}
#end
