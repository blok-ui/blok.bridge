package blog.ui;

import blok.html.HtmlEvents;

class Panel extends Component {
	@:attribute final styles:ClassName = null;
	@:attribute final children:Children;
	@:attribute final onClick:EventListener = null;

	function render() {
		return Html.div()
			.style(Breeze.compose(
				Border.radius(2),
				Border.color('black', 0),
				Border.width(.5),
				Spacing.pad(4),
				styles
			))
			.child(children);
	}
}
