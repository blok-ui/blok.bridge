package blok.bridge.plugin;

import blok.data.Structure;
import blok.html.server.*;

using StringTools;
using haxe.io.Path;

enum abstract HtmlGenerationStrategy(String) to String from String {
	final DirectoryWithIndexHtmlFile;
	final NamedHtmlFile;
}

typedef OutputHtmlEntry = {
	public final path:String;
	public final document:NodePrimitive;
}

class StaticHtml extends Structure implements Plugin {
	@:constant final strategy:HtmlGenerationStrategy;

	public function register(bridge:Bridge) {
		final entries:Array<OutputHtmlEntry> = [];

		bridge.events.renderComplete.add(rendered -> {
			var path = rendered.path.trim().normalize();
			if (path.startsWith('/')) path = path.substr(1);
			entries.push({path: path, document: rendered.document});
		});

		bridge.events.outputting.add(output -> output.enqueue(
			Task.parallel(...entries.map(entry -> {
				var head = entry.document
					.find(el -> el.as(ElementPrimitive)?.tag == 'head', true)
					.or(() -> new ElementPrimitive('head'));
				var body = entry.document
					.find(el -> el.as(ElementPrimitive)?.tag == 'body', true)
					.or(() -> new ElementPrimitive('body'));
				var html = '<!doctype html><html>${head.toString({ includeTextMarkers: false })}${body.toString()}</html>';

				var file = switch strategy {
					case DirectoryWithIndexHtmlFile:
						bridge.output.file(Path.join([entry.path, 'index.html']));
					case NamedHtmlFile if (entry.path == ''):
						bridge.output.file('index.html');
					case NamedHtmlFile:
						bridge.output.file(entry.path.withExtension('html'));
				}

				file.write(html)
					.next(_ -> file.getMeta())
					.next(meta -> {
						output.includeFile(meta.path);
						Task.nothing();
					});
			}))
		));

		bridge.events.cleanup.add(cleanup -> {
			cleanup.addDisposable(() -> entries.resize(0));
		});
	}
}
