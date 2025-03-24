package spa.routes;

import blok.html.Html;
import blok.*;
import blok.router.Page;

class HomePage extends Page<'/'> {
	function render():Child {
		return Html.p()
			.child(EditTask.link({id: 'One'}).child('One'))
			.child('Hello world');
	}
}
