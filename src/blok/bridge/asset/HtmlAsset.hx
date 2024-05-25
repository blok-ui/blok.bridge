package blok.bridge.asset;

using StringTools;
using haxe.io.Path;

class HtmlAsset implements Asset {
	final path:String;
	final html:String;

	public function new(path, html) {
		this.path = path;
		this.html = html;
	}

	public function getIdentifier():Null<String> {
		return '__blok.html<${path}>';
	}

	public function toString() {
		return html;
	}

	public function process(app:AppContext):Task<Nothing> {
		var path = path.trim().normalize();
		if (path.startsWith('/')) path = path.substr(1);

		return switch app.config.generator.strategy {
			case DirectoryWithIndexHtmlFile:
				app.publicDirectory
					.file(Path.join([path, 'index.html']))
					.write(toString());
			case NamedHtmlFile if (path == ''):
				app.publicDirectory
					.file('index.hxml')
					.write(toString());
			case NamedHtmlFile:
				app.publicDirectory
					.file(path.withExtension('html'))
					.write(toString());
		}
	}
}
