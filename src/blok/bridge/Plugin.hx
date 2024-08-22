package blok.bridge;

import blok.ui.Child;
import blok.html.server.*;

// @todo: Not sure if this is the API we really want, but for now...
@:autoBuild(blok.bridge.PluginBuilder.build())
interface Plugin {
	public function getPluginIdentifier():String;
	public function render(app:App, root:Child):Child;
	public function visited(app:App, path:String, document:NodePrimitive):Void;
	public function output(app:App):Task<Nothing>;
	public function cleanup():Void;
	public function toJson():Dynamic;
}
