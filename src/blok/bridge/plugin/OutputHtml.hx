package blok.bridge.plugin;

import blok.ui.Child;
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

class OutputHtml implements Plugin {
	@:auto final strategy:HtmlGenerationStrategy;

	final entries:Array<OutputHtmlEntry> = [];

	public function render(app:App, root:Child):Child {
		return root;
	}

	public function visited(app:App, path:String, document:NodePrimitive) {
		var path = path.trim().normalize();
		if (path.startsWith('/')) path = path.substr(1);

		entries.push({path: path, document: document});
	}

	public function output(app:App):Task<Nothing> {
		return Task.parallel(...entries.map(entry -> {
			var head = entry.document
				.find(el -> el.as(ElementPrimitive)?.tag == 'head', true)
				.or(() -> new ElementPrimitive('head'));
			var body = entry.document
				.find(el -> el.as(ElementPrimitive)?.tag == 'body', true)
				.or(() -> new ElementPrimitive('body'));
			var html = '<!doctype html><html>${head.toString({ includeTextMarkers: false })}${body.toString()}</html>';

			switch strategy {
				case DirectoryWithIndexHtmlFile:
					app.output
						.file(Path.join([entry.path, 'index.html']))
						.write(html);
				case NamedHtmlFile if (entry.path == ''):
					app.output
						.file('index.html')
						.write(html);
				case NamedHtmlFile:
					app.output
						.file(entry.path.withExtension('html'))
						.write(html);
			}
		}));
	}

	public function cleanup() {
		entries.resize(0);
	}
}
