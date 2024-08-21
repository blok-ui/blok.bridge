package blok.bridge;

import blok.html.server.*;

// @todo: Not sure if this is the API we really want, but for now...
@:autoBuild(blok.bridge.PluginBuilder.build())
interface Plugin {
	public function getPluginIdentifier():String;
	public function handleGeneratedPath(app:App, path:String, document:NodePrimitive):Void;
	public function handleOutput(app:App):Task<Nothing>;
	public function toJson():Dynamic;
}
