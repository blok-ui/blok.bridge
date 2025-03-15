package blok.bridge;

import blok.html.Html;

enum AssetType {
	CssAsset(path:String);
	JsAsset(path:String);
}

class Asset extends Component {
	@:attribute final type:AssetType;

	function render():Child {
		AssetContext.from(this).add(switch type {
			case CssAsset(path):
				Html.view(<link href=path type='text/css' rel='stylesheet'/>);
			case JsAsset(path):
				Html.view(<script defer src=path />);
				// @todo: inline js + css?
		});

		return Placeholder.node();
	}
}
