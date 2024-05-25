package blok.bridge.macro;

import haxe.Json;
import sys.io.File;
import haxe.macro.Type.ModuleType;
import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.Tools;
using haxe.io.Path;
using sys.FileSystem;

private var initialized:Bool = false;

function run() {
	if (initialized) return;
	initialized = true;

	Context.onAfterTyping(types -> {
		var islands = gatherIslands(types);
		exportManifest(islands);
	});
}

function loadManifest():Array<String> {
	var content = File.getContent(getManifestPath());
	if (content != null) return Json.parse(content).islands;
	return [];
}

private function getManifestPath() {
	var name = Context.definedValue('blok.generator.manifest') ?? '__blok_bridge_manifest';
	var artifacts = Context.definedValue('blok.generator.artifacts') ?? '__blok_bridge_artifacts';
	return Path.join([getRootPath(), artifacts, name]).withExtension('json');
}

private function getRootPath() {
	var output = Sys.getCwd();
	if (output.extension().length != 0) {
		return output.directory();
	}
	return output;
}

private function gatherIslands(types:Array<ModuleType>) {
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

private function exportManifest(islands:Array<String>) {
	var path = getManifestPath();
	ensureDir(path);
	File.saveContent(path, Json.stringify({
		islands: islands
	}));
}

private function getExportFilename() {
	var name = Context.definedValue('blok.bridge.manifest') ?? '__blok_bridge_manifest';
}

private function ensureDir(path:String) {
	var directory = path.directory();
	if (!directory.exists()) {
		ensureDir(directory);
		directory.createDirectory();
	}
	return path;
}
