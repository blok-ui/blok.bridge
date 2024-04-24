package blok.bridge;

import blok.bridge.asset.*;
import blok.html.Html;
import blok.ui.*;

class BridgeClient extends Component {
	@:attribute final output:String = 'app.js';
	@:attribute final main:String = 'Island';
	@:attribute final sources:Array<String> = null;
	@:attribute final libraries:Array<String> = null;
	@:attribute final flags:Map<String, Dynamic> = [];
	@:computed final assetPath:String = AppContext.from(this).config.paths.createAssetPath(output);

	function setup() {
		var context = AppContext.from(this);
		var islands = IslandContext.from(this);
		context.addAsset(new ClientAppAsset({
			sources: sources,
			libraries: libraries,
			output: output,
			main: main,
			flags: flags
		}, islands));
	}

	function render():Child {
		return Html.script({src: assetPath});
	}
}
