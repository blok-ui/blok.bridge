package blok.bridge.plugin;

import blok.html.server.*;

using haxe.io.Path;

// @todo: Allow copying and stuff
// @todo: Allow priority
enum Asset {
	CssAsset(path:String);
	JsAsset(path:String);
	InlineJs(contents:String, ?defer:Bool);
}

typedef AssetFormatter = (path:String) -> String;

class LinkAssets implements Plugin {
	final assets:Array<Asset>;

	public function new(assets) {
		this.assets = assets;
	}

	public function register(bridge:Bridge) {
		bridge.events.renderComplete.add(event -> {
			var head = event.document
				.find(el -> el.as(ElementPrimitive)?.tag == 'head', true)
				.or(() -> new ElementPrimitive('head'));

			for (asset in assets) switch asset {
				case CssAsset(path):
					head.append(new ElementPrimitive('link', {
						href: path.normalize(),
						type: 'text/css',
						rel: 'stylesheet'
					}));
				case JsAsset(path):
					head.append(new ElementPrimitive('script', {
						defer: true,
						src: path.normalize()
					}));
				case InlineJs(contents, defer):
					var script = new ElementPrimitive('script', {
						defer: defer == true
					});
					script.append(new UnescapedTextPrimitive(contents));
					head.append(script);
			}
		});

		bridge.events.outputting.add(event -> {
			event.enqueue(bridge.output.getMeta().next(meta -> {
				for (asset in assets) switch asset {
					case CssAsset(path):
						event.includeFile(Path.join([meta.path, path]).normalize());
					case JsAsset(path):
						event.includeFile(Path.join([meta.path, path]).normalize());
					default:
				}
				Task.nothing();
			}));
		});
	}
}
