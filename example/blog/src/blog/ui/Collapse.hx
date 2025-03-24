package blog.ui;

import blok.foundation.collapse.*;
import blok.bridge.Island;

class Collapse extends Island {
	@:attribute final header:Children;
	@:children @:attribute final children:Children;

	function render() {
		return blok.foundation.collapse.Collapse.node({
			initialStatus: Expanded,
			child: Panel.node({
				children: [
					CollapseHeader.node({child: header}),
					CollapseBody.node({children: children})
				]
			})
		});
	}
}

class CollapseHeader extends Component {
	@:attribute final child:Child;

	function render() {
		var collapse = CollapseContext.from(this);
		return Html.button({
			className: Typography.fontWeight('bold'),
			onClick: _ -> collapse.toggle(),
		}).child(child);
	}
}

class CollapseBody extends Component {
	@:attribute final children:Children;

	function render() {
		return CollapseItem.node({
			child: Html.div()
				.style(Layout.overflow('hidden').with(Layout.boxSizing('border')))
				.child(
					Html.div()
						.style(Spacing.pad('15px'))
						.child(children)
				)
		});
	}
}
