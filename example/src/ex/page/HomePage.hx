package ex.page;

import ex.layout.MainLayout;
import blok.html.Html;
import blok.ui.*;
import Breeze;

class HomePage extends Component {
	function render():Child {
		return MainLayout.node({
			children: Html.div({
				className: Breeze.compose(
					Spacing.pad(3)
				)
			}).child('home page').node()
		});
	}
}
