package blok.bridge.plugin;

import blok.data.Model;

enum abstract AssetType(String) from String to String {
	final CssLink;
	final ScriptLink;
}

class Asset extends Model {
	@:constant public final type:AssetType;
	@:constant public final path:String;
}
