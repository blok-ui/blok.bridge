package blok.bridge.macro;

import blok.bridge.Constants;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ModuleType;
import sys.io.File;

using haxe.io.Path;
using haxe.macro.Tools;
using sys.FileSystem;

private var initialized:Bool = false;

function registerIslandHydrator() {
	if (Context.defined('display')) return;

	if (initialized) return;
	initialized = true;

	Context.onAfterTyping(types -> {
		var islands = gatherIslands(types);
		export(islands);
	});
}

private function gatherIslands(types:Array<ModuleType>):Array<String> {
	var names = [];
	for (type in types) switch type {
		case TClassDecl(c):
			var cls = c.get();
			if (cls.superClass?.t?.toString() == 'blok.bridge.Island') {
				names.push(c.toString());
			}
		default:
	}
	return names;
}

private function export(types:Array<String>) {
	var contents = generateMain(types);
	var path = getMainPath();
	ensureDir(path);
	File.saveContent(path, contents);
}

private function getMainPath() {
	var root = Sys.getCwd();
	if (root.extension().length != 0) {
		root = root.directory();
	}
	return Path.join([root, DotBridge, IslandsMain]).withExtension('hx');
}

private function generateMain(types:Array<String>) {
	var out:Array<Expr> = [];
	for (name in types) {
		var path = name.split('.');
		out.push(macro $p{path}.hydrateIslands(adaptor, options));
	}
	var body = macro function main() {
		var options = null; // for now
		var adaptor = new blok.html.client.ClientAdaptor();
		$b{out}
	}

	return body.toString();
}

private function ensureDir(path:String) {
	var directory = path.directory();
	if (!directory.exists()) {
		ensureDir(directory);
		directory.createDirectory();
	}
	return path;
}
