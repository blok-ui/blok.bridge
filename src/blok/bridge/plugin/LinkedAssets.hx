package blok.bridge.plugin;

import blok.html.server.*;

using haxe.io.Path;

// @todo: Allow copying and stuff
enum Asset {
	CssAsset(path:String, ?cacheBuster:Bool);
	JsAsset(path:String, ?cacheBuster:Bool);
}

class LinkedAssets implements Plugin {
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
				case CssAsset(path, cacheBust):
					var href = '/' + switch cacheBust {
						case true: path + '?' + kit.Hash.hash(path + bridge.version.toFileNameSafeString());
						default: path;
					}
					head.append(new ElementPrimitive('link', {
						href: href.normalize(),
						rel: 'stylesheet'
					}));
				case JsAsset(path, cacheBust):
					var src = '/' + switch cacheBust {
						case true: path + '?' + kit.Hash.hash(path + bridge.version.toFileNameSafeString());
						default: path;
					}
					head.append(new ElementPrimitive('script', {
						defer: true,
						src: src.normalize()
					}));
			}
		});

		bridge.events.outputting.add(event -> {
			event.enqueue(bridge.output.getMeta().next(meta -> {
				for (asset in assets) switch asset {
					case CssAsset(path, _):
						event.includeFile(Path.join([meta.path, path]).normalize());
					case JsAsset(path, _):
						event.includeFile(Path.join([meta.path, path]).normalize());
				}
				Task.nothing();
			}));
		});
	}
}
