package blog.route;

import blog.layout.MainLayout;
import haxe.Timer;
import blok.router.Page;

class DelayRoute extends Page<'/delay'> {
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
