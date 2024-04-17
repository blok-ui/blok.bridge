package ex.layout;

import blok.bridge.AppContext;
import blok.router.Link;
import blok.html.Html;
import blok.ui.*;

class MainLayout extends Component {
	@:children @:attribute final children:Children;

	function render() {
		return Html.html().child([
			Html.head(),
			Html.body().child([
				Html.header().child([
					Html.h1().child('Example'),
					Html.nav().child(
						Html.ul().child([
							Html.li().child(Link.to('/counter/2').child('Counter'))
						])
					)
				]),
				Html.main().child(children),
				// @todo: Replace this with some kind of Assets component that
				// will do this automatically.
				Html.script().attr('src', AppContext.from(this).project.getPaths().createAssetPath('app.js'))
			])
		]);
	}
}
