package blok.bridge.plugin;

enum abstract AssetType(String) from String to String {
	final CssLink;
	final ScriptLink;
}

@:build(blok.bridge.ConfigBuilder.buildWithJsonSerializer())
class Asset {
	@:auto public final type:AssetType;
	@:auto public final path:String;
}
