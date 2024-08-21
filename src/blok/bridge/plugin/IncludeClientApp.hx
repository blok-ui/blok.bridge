package blok.bridge.plugin;

import blok.html.server.*;

class IncludeClientApp implements Plugin {
	@:auto public final minify:Bool = false;

	public function handleGeneratedPath(app:App, path:String, document:NodePrimitive) {
		document.find(el -> el.as(ElementPrimitive)?.tag == 'head', true)
			.inspect(head -> head.append(new ElementPrimitive('script', {
				defer: true,
				// @todo: switch to minified if needed
				src: app.paths.clientApp
			})));
	}

	public function handleOutput(app:App):Task<Nothing, Error> {
		// @todo: Output minified here.
		return Task.nothing();
	}
}
