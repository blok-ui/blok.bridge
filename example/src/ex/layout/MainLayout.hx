package ex.layout;

import blok.bridge.*;
import blok.router.Link;
import blok.html.Html;
import blok.ui.*;

class MainLayout extends Component {
	@:children @:attribute final children:Children;
	@:attribute final pageTitle:String = null;

	function render() {
		var app = AppContext.from(this);
		var paths = app.config.paths;
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
					href: paths.createAssetPath('styles-v0_0_1.css'),
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
				// The `blok.bridge.Client` component is required to output
				// client-side code. Islands will not work without this.
				//
				// Note: Annoyingly, we *do* need to repeat a lot of configuration
				// here. Higher-level frameworks -- like Blok Tower -- should
				// be able to handle this for us, but we can't inspect configuration
				// from an HXML file easily.
				BridgeClient.node({
					output: 'app.js',
					sources: ['src', 'example/src'],
					dependencies: ['breeze'],
					flags: [
						'breeze.output' => 'none'
					]
				})
			])
		]);
	}
}
