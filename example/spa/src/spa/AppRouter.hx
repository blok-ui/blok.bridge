package spa;

import blok.html.Html;
import blok.*;
import blok.bridge.*;
import blok.router.*;
import spa.routes.*;

class AppRouter extends Island {
	// This line is all that's needed to ensure the Router's navigation
	// is available on the client side.
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
