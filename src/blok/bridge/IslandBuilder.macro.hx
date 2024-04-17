package blok.bridge;

import blok.macro.*;
import blok.macro.builder.*;
import blok.ui.ComponentBuilder.builderFactory;

using Lambda;
using haxe.macro.Tools;

function build() {
	return builderFactory.withBuilders(
		new JsonSerializerBuilder({
			constructorAccessor: macro node,
			returnType: macro :blok.ui.Child
		}),
		new IslandBuilder()
	).fromContext().export();
}

class IslandBuilder implements Builder {
	public final priority:BuilderPriority = Late;

	public function new() {}

	public function apply(builder:ClassBuilder) {
		var path = builder.getType().follow().toComplexType().toString();

		builder.add(macro class {
			public static final islandName = $v{path};

			#if blok.client
			public static function hydrateIslands(adaptor:blok.adaptor.Adaptor) {
				var elements = blok.bridge.IslandElement.getIslandElementsForComponent(islandName);
				return [
					for (el in elements) {
						var props:{} = blok.bridge.IslandElement.getIslandProps(el);
						var cursor = adaptor.createCursor(el);
						var root = blok.ui.Root.node({
							target: el,
							child: () -> fromJson(props)
						}).createComponent();
						root.hydrate(cursor, adaptor, null, null);
						root;
					}
				];
			}
			#end

			function __islandName() {
				return islandName;
			}
		});
	}
}
