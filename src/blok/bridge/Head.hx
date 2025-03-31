package blok.bridge;

import blok.bridge.RequestContext;
import blok.html.Html;

using haxe.io.Path;

class Head extends Component {
	@:attribute final includeClient:Bool = true;
	@:children @:attribute final children:Children = [];

	function render():Child {
		return Html.view(<head>
			{children}
			{if (includeClient) 
				<script defer src={RequestContext.from(this).config.clientSrc} />
			else null}
			<SuspenseBoundary>
				<Scope>{context -> AssetContext.from(context).list()}</Scope>
				<fallback>{() -> ''}</fallback>
			</SuspenseBoundary>
		</head>);
	}
}
