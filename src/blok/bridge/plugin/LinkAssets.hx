package blok.bridge.plugin;

import blok.ui.Child;
import blok.html.server.*;

class LinkAssets implements Plugin {
	@:constant final links:Array<Asset>;

	public function render(app:App, root:Child):Child {
		return root;
	}

	public function visited(app:App, path:String, document:NodePrimitive) {
		var head = document
			.find(el -> el.as(ElementPrimitive)?.tag == 'head', true)
			.or(() -> new ElementPrimitive('head'));
		var body = document
			.find(el -> el.as(ElementPrimitive)?.tag == 'body', true)
			.or(() -> new ElementPrimitive('body'));

		for (link in links) switch link.type {
			case CssLink:
				head.append(new ElementPrimitive('link', {
					href: link.path,
					rel: 'stylesheet'
				}));
			case ScriptLink:
				body.append(new ElementPrimitive('script', {
					defer: true,
					src: link.path
				}));
		}
	}

	public function output(app:App):Task<Nothing> {
		return Task.nothing();
	}

	public function cleanup() {}
}
