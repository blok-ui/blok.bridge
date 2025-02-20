package blok.bridge.component;

import blok.html.Html;
import blok.*;
import kit.Error;

class DefaultErrorView extends Component {
	@:attribute final code:ErrorCode = InternalError;
	@:attribute final title:Maybe<String> = None;
	@:attribute final message:String;

	function render():Child {
		var title = title.or(() -> 'Error ' + code);

		return Html.html().child(
			Html.head().child(
				Html.title().child(title)
			),
			Html.body().child(
				Html.header().child(
					Html.h1().child(title)
				),
				Html.div().child(
					Html.p().child(message)
				)
			)
		);
	}
}
