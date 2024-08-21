package blok.bridge;

class Bridge {
	#if blok.client
	public macro static function hydrateIslands();
	#else
	public static function generate(app, render, plugins) {
		var generator = new blok.bridge.Generator(app, render, plugins);
		return generator.generate().handle(result -> switch result {
			case Ok(_): trace("Complete"); // @todo: make customizable
			case Error(e): trace(e);
		});
	}
	#end
}
