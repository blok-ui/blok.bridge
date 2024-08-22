package blok.bridge.plugin;

import blok.ui.Child;
import blok.html.server.*;

class IncludeClientApp implements Plugin {
	@:auto public final src:String;
	@:auto public final minify:Bool = false;

	public function render(app:App, root:Child):Child {
		return root;
	}

	public function visited(app:App, path:String, document:NodePrimitive) {
		document.find(el -> el.as(ElementPrimitive)?.tag == 'head', true)
			.inspect(head -> head.append(new ElementPrimitive('script', {
				defer: true,
				// @todo: switch to minified if needed
				src: src
			})));
	}

	public function output(app:App):Task<Nothing, Error> {
		// @todo: Output minified here.
		return Task.nothing();
	}

	public function cleanup() {}
}
