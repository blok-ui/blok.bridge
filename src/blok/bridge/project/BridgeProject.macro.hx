package blok.bridge.project;

import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

using Reflect;
using haxe.io.Path;

class BridgeProject {
	public static function embed():Expr {
		function search(dir:String):Maybe<String> {
			var path = Path.join([dir, 'project.toml']);
			if (FileSystem.exists(path)) return Some(File.getContent(path));
			var upOne = dir.directory();
			if (FileSystem.isDirectory(upOne)) return search(upOne);
			return None;
		}

		return search(Sys.getCwd()).map(value -> {
			var data:{} = Toml.parse(value);
			var expr = toObject(data);
			macro blok.bridge.project.BridgeProject.fromJson($expr);
		}).or(() -> {
			Context.error('Could not find a project.toml in the current working directory or in any parent directories.', Context.currentPos());
		});
	}
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
