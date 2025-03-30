package blok.bridge.component;

import blok.html.Html;

class DefaultSuspenseView extends Component {
	function render():Child {
		return Html.html().child(
			Html.head(),
			Html.body().child(
				Html.div().child('Loading...'),
				#if debug
				Html.p().child('Warning: this is Blok\'s default SuspenseView! You should probably implement your own.')
				#end
			)
		);
	}
}
