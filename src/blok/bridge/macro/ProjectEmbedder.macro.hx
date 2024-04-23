package blok.bridge.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

using Reflect;
using haxe.io.Path;

function embed(factory:Expr) {
	var path = Path.join([Sys.getCwd(), 'project.toml']);

	if (!FileSystem.exists(path)) {
		Context.error('Could not find a project.toml in the current working directory.', Context.currentPos());
	}

	var value = File.getContent(path);
	var data:{} = Toml.parse(value);
	var expr = toObject(data);

	return macro $factory($expr);
}

private function toExpr(value:Dynamic):Expr {
	if (value is String || value is Bool || value is Int) {
		return macro $v{value};
	}
	if (value is Array) {
		var arr:Array<Dynamic> = value;
		var exprs = arr.map(toExpr);
		return macro [$a{exprs}];
	}
	return toObject(value);
}

private function toObject(data:{}):Expr {
	var objectFields:Array<ObjectField> = [];
	for (field in data.fields()) {
		var value:Dynamic = data.field(field);
		objectFields.push({
			field: field,
			expr: toExpr(value)
		});
	}
	return {
		expr: EObjectDecl(objectFields),
		pos: Context.currentPos()
	};
}
