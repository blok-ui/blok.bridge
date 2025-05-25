package blog.layout;

import blok.bridge.*;
import blog.route.*;
import blog.data.*;
import blog.ui.Dropdown;

using blok.foundation.dropdown.DropdownModifiers;

class MainLayout extends Component {
	@:attribute final pageTitle:Null<String>;
	@:attribute final children:Children;
	@:resource final posts:Array<Post> = PostStore.from(this).all();

	function render():Child {
		return Html.html().child([
			Head.node({
				children: [
					Html.title().child(['Blogish ', pageTitle]).node(),
					Html.link({href: '/assets/styles.css', rel: 'stylesheet'})
				]
			}),

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
						HomeRoute.link()
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
												ArchiveRoute.link({
													page: 1
												}).child('Archive')
											),
										Html.li().child(
											CounterRoute.link({initial: 2}).child('Counter')
										),
										Html.li().child(
											DelayRoute.link().child('Delay')
										),
										Html.li().child(
											Dropdown.node({
												label: 'Posts',
												children: [for (post in posts())
													PostRoute.link({id: post.slug})
														.child(post.title)
														.node()
														.asDropdownItem()
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
					.child(children)
			])
		]);
	}
}
