package spa;

import blok.html.Html;
import blok.*;
import blok.bridge.*;
import blok.router.*;
import spa.home.*;
import spa.note.EditNotePage;

class AppHeader extends Island {
	@:context final navigator:Navigator;

	function render():Child {
		return Html.view(<header>
			<h1><Link to={HomePage.createUrl()}>"Spa Example"</Link></h1>
			<nav>
				<ul>
					<li><Link to={EditNotePage.createUrl({id: 'test'})}>"Test"</Link></li>
				</ul>
			</nav>
		</header>);
	}
}
