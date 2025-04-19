package spa.ui;

import Breeze;
import blok.html.Html;
import blok.*;

class PageLayout extends Component {
	@:attribute final name:String;
	@:children @:attribute final children:Children;

	function render():Child {
		return Html.view(<div className={Breeze.compose(
			Spacing.pad(3)
		)}>
			<header>
				<h1>name</h1>
			</header>
			<div>
				children
			</div>
		</div>);
	}
}
