import ex.page.*;
import blok.router.*;
import blok.bridge.Bridge;

// @todo: This file should be generated automatically. We should
// only have to define a Routes file.
function main() {
	#if blok.client
	Bridge.startIslands();
	#else
	Bridge
		.start(() -> Router.node({
			routes: [
				new Route<'/'>(_ -> HomePage.node({})),
				new Route<'/counter/{count:Int}'>(params -> CounterPage.node({initialCount: params.count}))
			],
			fallback: _ -> 'Not found'
		}))
		.generate()
		.next(app -> app.process())
		.handle(result -> switch result {
			case Ok(_): trace('Created');
			case Error(error): trace(error.message);
		});
	#end
}
