package ex.layout;

import blok.bridge.AppContext;
import blok.router.Link;
import blok.html.Html;
import blok.ui.*;

class MainLayout extends Component {
	@:children @:attribute final children:Children;
	@:attribute final pageTitle:String = null;

	function render() {
		var app = AppContext.from(this);
		var version = app.project.getMeta().version.toFileNameSafeString();
		var paths = app.project.getPaths();
		var title = Html.title().child('Example');

		if (pageTitle != null) {
			title.child(' | ').child(pageTitle);
		}

		return Fragment.node([
			Html.head().child([
				title,
				// @todo: Replace this with some kind of Assets component that
				// will do this automatically.
				Html.link({
					href: paths.createAssetPath('styles-${version}.css'),
					rel: 'stylesheet'
				})
			]),
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
				Html.script({
					src: paths.createAssetPath('app.js')
				})
			])
		]);
	}
}
