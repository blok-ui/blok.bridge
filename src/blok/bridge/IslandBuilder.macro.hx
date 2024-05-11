package blok.bridge;

import kit.macro.*;
import kit.macro.parser.*;
import blok.ui.ComponentBuilder.factory;

using Lambda;
using haxe.macro.Tools;

function build() {
	return factory.withParsers(
		new JsonSerializerParser({
			customParser: options -> switch options.type.toType().toComplexType() {
				case macro :blok.signal.Signal<$wrappedType>:
					var name = options.name;
					Some(options.parser(macro this.$name.get(), name, wrappedType));
				default:
					None;
			},
			constructorAccessor: macro node,
			returnType: macro :blok.ui.Child
		}),
		new IslandBuilder()
	).fromContext().export();
}

class IslandBuilder implements Parser {
	public final priority:Priority = Late;

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
