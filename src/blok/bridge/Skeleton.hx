package blok.bridge;

import blok.signal.Signal;

/**
	When wrapped in this component, children will:

	- *not* be rendered on the server at all;
	- will *not* be hydrated on the client, but will be initialized once hydration
	is completed.

	This makes this component ideal for situations where you need client-side behavior
	that don't work well coming from the server. To further support this, children are
	automatically wrapped in a SuspenseBoundary that uses the same fallback as the 
	Skeleton, which allows patterns like the following:

	```haxe
	// Note that we wrap this in an Island to make it available on the client:
	class ClientSideOnly extends Island {
		function render() {
			return Html.view(<Skeleton>
				// This fallback will be rendered on the server and initially hydrated on the 
				// client, which means you'll see the loading spinner with no flicker:
				<fallback>{() -> </LoadingSpinner>}</fallback>	
				// The following will *only* be run on the client and is automatically
				// wrapped in a SuspenseBoundary:
				{() -> {
					var loader = SomeClientSideLoader.from(this).doSomethingThatSuspends();
					<p>${loader.content}</p>
				}}
			</Skeleton>);
		}
	}
	```
**/
class Skeleton extends Component {
	public static inline function wrap(child) {
		return Skeleton.node({child: child});
	}

	@:attribute final fallback:() -> Child = () -> Placeholder.node();
	@:attribute final onSuspended:() -> Void = null;
	@:attribute final onComplete:() -> Void = null;
	@:children @:attribute final child:() -> Child;

	final hydrating:Signal<Bool> = new Signal(false);

	function render() {
		var env = Root.from(this).adaptor.environment;

		if (env.server) return fallback();

		hydrating.set(investigate().isHydrating());

		return if (hydrating()) {
			fallback();
		} else {
			SuspenseBoundary.node({
				onSuspended: onSuspended,
				onComplete: onComplete,
				fallback: fallback,
				child: Scope.wrap(_ -> child())
			});
		}
	}

	function setup() {
		// This is a bit of a hack: if `hydrating` was false this
		// will trigger a re-render (as `setup` is run *after*
		// rendering and mounting the component).
		hydrating.set(false);
	}
}
