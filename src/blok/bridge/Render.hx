package blok.bridge;

@:callable
@:forward
abstract Render(() -> Child) from () -> Child to () -> Child {
	public inline function new(impl) {
		this = impl;
	}

	public inline function render() {
		return this();
	}
}
