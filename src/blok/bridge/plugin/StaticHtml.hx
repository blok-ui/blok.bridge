package blok.bridge.plugin;

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

class StaticHtml extends Plugin {
	@:value final strategy:HtmlGenerationStrategy;

	public function run() {
		var entries:Array<OutputHtmlEntry> = [];
		var render = Generator.from(this);
		var core = Lifecycle.from(this);
		var output = Output.maybeFrom(this).orThrow('Output required for StaticHtml');
		var links:Cancellable = [
			render.renderComplete.add((path, document) -> {
				var path = path.trim().normalize();
				if (path.startsWith('/')) path = path.substr(1);
				entries.push({path: path, document: document});
			}),

			core.export.add(queue -> queue.enqueue(
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
							output.directory.file(if (entry.path.extension() == '') {
								Path.join([entry.path, 'index.html']);
							} else {
								entry.path;
							});
						case NamedHtmlFile if (entry.path == ''):
							output.directory.file('index.html');
						case NamedHtmlFile:
							output.directory.file(entry.path.withExtension('html'));
					}

					return file.write(html)
						.next(_ -> file.getMeta())
						.next(meta -> {
							output.include(meta.path);
							Task.nothing();
						});
				})).next(_ -> {
					Logging.maybeFrom(this).inspect(logger -> logger.log(Info, 'Html exported'));
					Task.nothing();
				})
			)),

			core.cleanup.add(_ -> entries.resize(0)),
		];

		addDisposable(() -> links.cancel());
	}
}
