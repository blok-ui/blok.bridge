package blok.bridge.generate;

import kit.file.Directory;

using StringTools;
using haxe.io.Path;

class GeneratedHtml {
	final path:String;
	final html:String;

	public function new(path, html) {
		this.path = path;
		this.html = html;
	}

	public function toString() {
		return html;
	}

	public function output(strategy:HtmlGenerationStrategy, output:Directory):Task<Nothing> {
		var path = path.trim().normalize();
		if (path.startsWith('/')) path = path.substr(1);

		return switch strategy {
			case DirectoryWithIndexHtmlFile:
				output
					.file(Path.join([path, 'index.html']))
					.write(toString());
			case NamedHtmlFile if (path == ''):
				output
					.file('index.html')
					.write(toString());
			case NamedHtmlFile:
				output
					.file(path.withExtension('html'))
					.write(toString());
		}
	}
}
