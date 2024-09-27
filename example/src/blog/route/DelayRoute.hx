package blog.route;

import blok.suspense.SuspenseBoundary;
import blog.layout.MainLayout;
import haxe.Timer;
import blok.router.RouteComponent;

class DelayRoute extends RouteComponent<'/delay'> {
	@:resource final delay:String = new Task(activate -> {
		Timer.delay(() -> activate(Ok('Completed')), 100);
	});

	public function render():Child {
		return MainLayout.node({
			pageTitle: 'Delay',
			children: SuspenseBoundary.node({
				child: Scope.wrap(_ -> Html.p().child(delay())),
				fallback: () -> 'loading...'
			})
		});
	}
}
