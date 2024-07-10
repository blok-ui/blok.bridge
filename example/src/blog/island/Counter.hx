package blog.island;

import blok.bridge.*;

class Counter extends Island {
	@:signal final count:Int = 0;

	function render():Child {
		return Html.div()
			.style(Breeze.compose(
				Background.color('black', 0),
				Typography.textColor('white', 0),
				Typography.fontWeight('bold'),
				Spacing.pad(3),
				Spacing.margin(10),
				Border.radius(3)
			))
			.child([
				Html.div().child(count),
				CounterButton.node({
					onClick: () -> count.update(i -> i + 1),
					children: '+'
				})
			]);
	}
}

class CounterButton extends Component {
	@:attribute final onClick:() -> Void;
	@:children @:attribute final children:Children;

	function render() {
		return Html.button()
			.style(Breeze.compose(
				Background.color('white', 0),
				Typography.textColor('red', 500),
				Typography.fontWeight('bold'),
				Spacing.pad(3),
				Border.radius(3)
			))
			.on(Click, _ -> onClick())
			.child(children);
	}
}
