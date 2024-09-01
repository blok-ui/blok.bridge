package blok.bridge.macro;

import blok.bridge.Constants;
import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Type.ModuleType;
import sys.io.File;

using haxe.io.Path;
using haxe.macro.Tools;
using sys.FileSystem;

private var initialized:Bool = false;

function registerIslandTracker() {
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
	var root = Sys.getCwd();
	if (root.extension().length != 0) {
		root = root.directory();
	}
	return Path.join([root, DotBridge, Manifest]).withExtension('json');
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

private function ensureDir(path:String) {
	var directory = path.directory();
	if (!directory.exists()) {
		ensureDir(directory);
		directory.createDirectory();
	}
	return path;
}
