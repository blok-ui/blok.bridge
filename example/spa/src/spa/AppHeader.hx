package spa;

import blok.html.Html;
import blok.*;
import blok.bridge.*;
import blok.router.*;
import spa.routes.*;

class AppHeader extends Island {
	@:context final navigator:Navigator;

	function render():Child {
		return Html.view(<header>
			<h1><Link to={HomePage.createUrl()}>"Spa Example"</Link></h1>
			<nav>
				<ul>
					<li><Link to={EditNote.createUrl({id: 'test'})}>"Test"</Link></li>
				</ul>
			</nav>
		</header>);
	}
}
