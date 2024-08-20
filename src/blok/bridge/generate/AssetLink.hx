package blok.bridge.generate;

@:using(blok.bridge.generate.AssetLink.AssetLinkTools)
enum AssetLink {
	CssLink(path:String);
	ScriptLink(path:String);
}

class AssetLinkTools {
	public static function serialize(link:AssetLink) {
		return switch link {
			case CssLink(path): 'blok.bridge.generate.AssetLink.CssLink("$path")';
			case ScriptLink(path): 'blok.bridge.generate.AssetLink.ScriptLink("$path")';
		}
	}
}
