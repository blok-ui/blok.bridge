package blog.layout;

import blok.bridge.AppContext;
import blog.route.*;

class MainLayout extends Component {
	@:attribute final pageTitle:Null<String>;
	@:attribute final children:Children;

	function render():Child {
		var app = AppContext.from(this);

		return Fragment.of([
			Html.head().child([
				Html.title().child(['Blogish ', pageTitle]),
				Html.link()
					.attr('href', app.config.paths.createAssetPath(app.config.applyVersionToFileName('styles.css')))
					.attr('rel', 'stylesheet')
			]).node(),
			Html.body().child([
				Html.header()
					.style(Breeze.compose(
						Flex.display(),
						Flex.direction('row'),
						Flex.alignItems('center'),
						Flex.gap(3),
						Sizing.width('100%'),
						Sizing.height(15),
						Background.color('black', 0),
						Typography.textColor('white', 0),
					))
					.child([
						Home.link({})
							.child(Html.h3().child('Blogish')),

						Html.nav()
							.child([
								Html.ul()
									.style(Breeze.compose(
										Flex.display(),
										Flex.direction('row'),
										Flex.gap(3),
									))
									.child([
										Html.li()
											.child(
												Archive.link({
													page: 1
												}).child('Archive')
											),
										Html.li().child(
											Counter.link({initial: 2}).child('Counter')
										),
										Html.li().child(
											Post.link({id: '01-first-post'}).child('Post 1')
										)
									])
							])
					]),

				Html.main()
					.style(Breeze.compose(
						Spacing.margin('y', 3),
						Spacing.margin('x', 'auto'),
						Sizing.width('100%'),
						Breakpoint.viewport('900px', Sizing.width('900px'))
					))
					.child(children),
				Html.script()
					.attr('src', app.config.paths.createAssetPath(app.config.getClientAppName()))
			])
		]);
	}
}
