package blok.bridge.asset;

class CssAsset implements Asset {
	public function getIdentifier():Null<String> {
		throw new haxe.exceptions.NotImplementedException();
	}

	public function process(context:AppContext):Task<Nothing, Error> {
		throw new haxe.exceptions.NotImplementedException();
	}
}
