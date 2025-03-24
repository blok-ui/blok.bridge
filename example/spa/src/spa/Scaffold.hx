package spa;

import spa.AppRouter;
import blok.bridge.Head;
import blok.html.Html;
import blok.*;

class Scaffold extends Component {
	function render():Child {
		return Html.html().child(
			Head.node({
				// @todo: Figure out some way to make SPA apps able to update
				// stuff like the title.
				children: [
					Html.title().child('SPA Example').node()
				]
			}),
			Html.body().child(
				AppRouter.node({})
			)
		);
	}
}
