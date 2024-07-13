package blog.layout;

import blog.route.*;
import blog.data.*;
import blog.ui.Dropdown;
import blok.bridge.AppContext;

class MainLayout extends Component {
	@:attribute final pageTitle:Null<String>;
	@:attribute final children:Children;
	@:resource final posts:Array<Post> = PostStore.from(this).all();

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
				Html.div().attr(Id, 'portal'),
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
										Flex.alignItems('center'),
										Sizing.height('full')
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
											Dropdown.node({
												label: 'Posts',
												children: [for (post in posts())
													blog.route.Post.link({id: post.slug}).child(post.title).node()
												]
											})
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
