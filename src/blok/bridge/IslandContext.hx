package blok.bridge;

import blok.debug.Debug;
import blok.context.Context;

@:fallback(error('No IslandContext found'))
class IslandContext implements Context {
	final islands:Array<String> = [];

	public function new() {}

	public function getIslandPaths():Array<String> {
		return islands;
	}

	public function registerIsland(islandPath:String) {
		trace('Registering $islandPath');
		if (!islands.contains(islandPath)) {
			islands.push(islandPath);
		}
	}

	public function dispose() {}
}
