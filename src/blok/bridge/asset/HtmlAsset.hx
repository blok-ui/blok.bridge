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
		return '<!doctype html>' + html;
	}

	public function process(context:AppContext):Task<Nothing> {
		var path = path.trim().normalize();
		if (path.startsWith('/')) path = path.substr(1);

		// @todo: Allow path to be configured so it can either be an
		// index.html in a folder *or* just directly naming the html file.
		return context.publicDirectory
			.file(Path.join([path, 'index.html']))
			.write(toString());
	}
}
