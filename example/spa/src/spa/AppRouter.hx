package spa;

import blok.html.Html;
import blok.*;
import blok.bridge.*;
import blok.router.*;
import spa.routes.*;

class AppRouter extends Island {
	@:context final navigator:Navigator;

	function render():Child {
		return Html.view(<div>
			<Router>
				<HomePage />
				<EditNote />
				<Route to="*">{_ -> 'Not found'}</Route>
			</Router>
		</div>);
	}
}
