package blok.bridge;

typedef ExtensionImpl = (bridge:Bridge) -> Void;

abstract Extension(ExtensionImpl) from ExtensionImpl {
	@:from public inline static function ofArray(extensions:Array<Extension>):Extension {
		return new Extension(bridge -> {
			bridge.use(...extensions);
		});
	}

	inline public function new(extension) {
		this = extension;
	}

	public inline function apply(bridge) {
		this(bridge);
	}
}
