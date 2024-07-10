package blog.ui;

class Heading extends Component {
	@:children @:attribute final children:Children;

	function render():Child {
		return Html.h1().style(Breeze.compose(
			Typography.fontSize('lg'),
			Typography.fontWeight('bold')
		)).child(children);
	}
}
