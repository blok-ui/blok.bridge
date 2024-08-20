package blok.bridge;

class Bridge {
	#if blok.client
	public macro static function hydrateIslands();
	#else
	public static function generate(options) {
		var generator = new blok.bridge.generate.Generator(options);
		return generator.generate().handle(result -> switch result {
			case Ok(_): trace("Complete"); // @todo: make customizable
			case Error(e): trace(e);
		});
	}
	#end
}
