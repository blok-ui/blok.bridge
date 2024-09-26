package blok.bridge;

import blok.ui.*;

@:autoBuild(blok.bridge.IslandBuilder.build())
abstract class Island extends ProxyView {
	abstract function toJson():Dynamic;

	abstract function __islandName():String;
}
