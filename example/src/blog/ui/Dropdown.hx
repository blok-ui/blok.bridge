package blog.ui;

import blok.bridge.*;

class Dropdown extends Island {
	@:attribute final label:String;
	@:attribute final children:Children;

	function render():Child {
		return Html.div().child(
			blok.foundation.dropdown.Dropdown.node({
				toggle: context -> Button.node({
					action: e -> {
						e.preventDefault();
						e.stopPropagation();
						context.toggle();
					},
					label: label
				}),
				child: _ -> Panel.node({
					styles: Breeze.compose(
						Background.color('white', 0),
						Sizing.width('min', '50px'),
						Layout.layer(10),
						Filter.dropShadow('xl')
					),
					children: Html.ul()
						.style(Breeze.compose(
							Flex.display(),
							Flex.gap(1),
							Flex.direction('column'),
							Spacing.pad(1)
						))
						.on(Click, e -> e.stopPropagation())
						.child(children)
				})
			})
		);
	}
}
