package blog.ui;

import blok.html.HtmlEvents;

enum ButtonPriority {
	Primary;
	Normal;
}

class Button extends Component {
	@:attribute final label:Child;
	@:attribute final priority:ButtonPriority = Normal;
	@:attribute final action:EventListener;

	function render():Child {
		return Html.button({
			className: Breeze.compose(
				Spacing.pad('y', 1),
				Spacing.pad('x', 3),
				Typography.fontWeight('bold'),
				Border.radius(2),
				Border.style('solid'),
				Border.width(.5),
				Border.color('black', 0),
				switch priority {
					case Primary: Background.color('sky', 200);
					case Normal: null;
				}
			),
			onClick: action
		}).child(label);
	}
}
