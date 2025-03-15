package blok.bridge;

import blok.bridge.BridgeRequest;
import blok.html.Html;

using haxe.io.Path;

class Head extends Component {
	@:children @:attribute final children:Children;

	function render():Child {
		var request = BridgeRequest.from(this);

		return Html.view(<head>
			{children}
			<script defer src={request.config.clientSrc} />
			<SuspenseBoundary>
				<Scope>{context -> AssetContext.from(context).list()}</Scope>
				<fallback>{() -> ''}</fallback>
			</SuspenseBoundary>
		</head>);
	}
}
