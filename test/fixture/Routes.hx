package fixture;

import haxe.Timer;
import haxe.Exception;
import blok.router.*;
import blok.*;

using Kit;
using blok.Modifiers;

class Routes extends Component {
	function render() {
		return Router.node({
			routes: [
				Route.to('/').renders(_ -> 'Home Page'),
				Route.to('/foo/{bar:String}').renders(props -> 'Foo ${props.bar}'),
				Route.to('/error').renders(_ -> throw new Error(InternalError, 'Expected failure')),
				Suspends.route({}),
				Route.to('*').renders(_ -> 'Not found')
			]
		}).inErrorBoundary((component, e) -> e.message);
	}
}

class Suspends extends Page<'/suspends'> {
	@:resource final tester:String = new Task(activate -> {
		Timer.delay(() -> activate(Ok('Suspended')), 500);
	});

	function render():Child {
		return tester();
	}
}
