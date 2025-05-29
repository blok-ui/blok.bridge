package blok.bridge;

import blok.signal.Signal;

class NoHydration extends Component {
	@:attribute final placeholder:Child = Placeholder.node();
	@:children @:attribute final child:() -> Child;

	final hydrating:Signal<Bool> = new Signal(false);

	function render() {
		var env = Root.from(this).adaptor.environment;

		if (env.server) return placeholder;

		hydrating.set(investigate().isHydrating());
		return if (hydrating()) placeholder else child();
	}

	function setup() {
		// This is a bit of a hack: if `hydrating` was false this
		// will trigger a re-render (as `setup` is run *after*
		// rendering and mounting the component).
		hydrating.set(false);
	}
}
