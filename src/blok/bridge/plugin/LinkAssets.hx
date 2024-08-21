package blok.bridge.plugin;

import blok.html.server.*;

class LinkAssets implements Plugin {
	@:auto final links:Array<Asset>;

	public function handleGeneratedPath(app:App, path:String, document:NodePrimitive) {
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

	public function handleOutput(app:App):Task<Nothing> {
		return Task.nothing();
	}
}
