import blok.bridge.Bootstrap;
import blok.router.*;
import blok.ui.*;
import ex.page.*;

class Routes extends Bootstrap {
	public function start():Child {
		return Router.node({
			routes: [
				new Route<'/'>(_ -> HomePage.node({})),
				new Route<'/counter/{count:Int}'>(params -> CounterPage.node({initialCount: params.count}))
			],
			fallback: _ -> 'Not found'
		});
	}
}
