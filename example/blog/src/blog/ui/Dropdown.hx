package blog.ui;

import blok.foundation.animation.*;
import blok.bridge.*;

class Dropdown extends Island {
	@:attribute final label:String;
	@:attribute final children:Children;

	function render():Child {
		return Html.div().child(
			blok.foundation.dropdown.Dropdown.node({
				showAnimation: new Keyframes('dropdown:show', _ -> [
					{opacity: 0, transform: 'translateY(-10px)'},
					{opacity: 1, transform: 'translateY(0)'}
				]),
				hideAnimation: new Keyframes('dropdown:hide', _ -> [
					{opacity: 1, transform: 'translateY(0)'},
					{opacity: 0, transform: 'translateY(-10px)'}
				]),
				transitionSpeed: 70,
				toggle: toggle -> Button.node({
					action: e -> {
						e.preventDefault();
						e.stopPropagation();
						toggle();
					},
					label: label
				}),
				child: Panel.node({
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
