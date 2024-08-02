package blok.bridge;

import kit.macro.*;
import kit.macro.step.*;
import blok.ui.ComponentBuilder;

using Lambda;
using haxe.macro.Tools;

function build() {
	return ClassBuilder.fromContext()
		.use(new ComponentBuilder())
		.step(new JsonSerializerBuildStep({
			customParser: options -> switch options.type.toType().toComplexType() {
				case macro :blok.signal.Signal<$wrappedType>:
					var name = options.name;
					Some(options.parser(macro this.$name.get(), name, wrappedType));
				case macro :blok.ui.Children:
					var name = options.name;
					Some({
						serializer: macro blok.bridge.SerializableChildren.toJson(this, this.$name),
						deserializer: macro blok.bridge.SerializableChildren.fromJson(Reflect.field(data, $v{name}))
					});
				// @todo: handle `blok.ui.Child` as well
				default:
					None;
			},
			constructorAccessor: macro node,
			returnType: macro :blok.ui.Child
		}))
		.step(new IslandBuilder())
		.export();
}

class IslandBuilder implements BuildStep {
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
