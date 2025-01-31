package blok.bridge.plugin;

import blok.html.server.*;

using haxe.io.Path;

enum Asset {
	TrackedFile(path:String);
	CssAsset(path:String);
	JsAsset(path:String);
	InlineJs(contents:String, ?defer:Bool);
}

class Assets extends Plugin {
	@:noUsing
	public static function maybeFrom(plugin:Plugin) {
		return plugin.findAncestorOfType(Assets);
	}

	@:value final assets:Array<Asset>;
	@:value final children:Array<Plugin> = [];

	public function addAsset(asset:Asset) {
		assets.push(asset);
	}

	public function run() {
		var link = Generator.from(this).renderComplete.add((_, document) -> {
			var head = document
				.find(el -> el.as(ElementPrimitive)?.tag == 'head', true)
				.or(() -> new ElementPrimitive('head'));

			for (asset in assets) switch asset {
				case TrackedFile(_):
					// ignore
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

		addDisposable(() -> link.cancel());

		Output.maybeFrom(this).inspect(output -> output.exporting.add(queue -> {
			queue.enqueue(output.directory.getMeta().next(meta -> {
				for (asset in assets) switch asset {
					case CssAsset(path) | JsAsset(path) | TrackedFile(path):
						var url = path.split('?')[0];
						output.include(Path.join([meta.path, url]).normalize());
					default:
				}
				Task.nothing();
			}));
		}));

		for (child in children) registerChild(child);
	}
}
