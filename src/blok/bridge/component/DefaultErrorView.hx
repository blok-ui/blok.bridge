package blok.bridge.component;

import blok.html.Html;
import blok.*;
import kit.Error;

class DefaultErrorView extends Component {
	@:attribute final title:Maybe<String> = None;
	@:attribute final error:Error;

	function render():Child {
		var title = title.or(() -> 'Error ' + error.code);

		return Html.html().child(
			Html.head().child(
				Html.title().child(title)
			),
			Html.body().child(
				Html.header().child(
					Html.h1().child(title)
				),
				Html.div().child(
					Html.p().child(error.message),
					#if debug
					Html.p().child('Warning: this is Blok\'s default ErrorView! You should probably implement your own.')
					#end
				)
			)
		);
	}
}
