package blok.bridge;

import kit.macro.*;
import kit.macro.step.*;
import blok.ComponentBuilder;

using Lambda;
using haxe.macro.Tools;

function build() {
	return ClassBuilder.fromContext()
		.addBundle(new ComponentBuilder())
		.addStep(new JsonSerializerBuildStep({
			customParser: options -> switch options.type.toType().toComplexType() {
				case macro :blok.signal.Signal<$wrappedType>:
					var name = options.name;
					Some(options.parser(macro this.$name.get(), name, wrappedType));
				case macro :blok.Children:
					var name = options.name;
					Some({
						serializer: macro blok.bridge.SerializableChildren.toJson(this, this.$name),
						deserializer: macro blok.bridge.SerializableChildren.fromJson(Reflect.field(data, $v{name}))
					});
				case macro :blok.Child:
					var name = options.name;
					Some({
						serializer: macro blok.bridge.SerializableChildren.toJson(this, this.$name),
						deserializer: macro blok.bridge.SerializableChildren.fromJson(Reflect.field(data, $v{name}))
					});
				default:
					None;
			},
			constructorAccessor: macro node,
			returnType: macro :blok.Child
		}))
		.addStep(new IslandBuilder())
		.export();
}

class IslandBuilder implements BuildStep {
	public final priority:Priority = Late;

	public function new() {}

	public function apply(builder:ClassBuilder) {
		var path = builder.getType().follow().toComplexType().toString();

		// Wrap our render result in an IslandElement if needed.
		builder.findField('render').inspect(field -> switch field.kind {
			case FFun(f):
				var render = f.expr;
				f.expr = macro {
					#if blok.client
					$render;
					#else
					var child:() -> blok.Child = () -> $render;
					return switch findAncestorOfType(blok.bridge.Island) {
						case None:
							blok.bridge.IslandElement.node({
								component: __islandName(),
								props: toJson(),
								child: child()
							});
						case Some(_):
							// We don't want to wrap nested Islands! Only top-level
							// Islands will need hydration.
							child();
					}
					#end
				}
			default:
		});

		builder.add(macro class {
			public static final islandName = $v{path};

			#if blok.client
			public static function hydrateIslands(adaptor:blok.Adaptor, ?options):blok.Disposable {
				var elements = blok.bridge.IslandElement.getIslandElementsForComponent(islandName, options);
				var islands = [
					for (el in elements) {
						var props:{} = blok.bridge.IslandElement.getIslandProps(el);
						var cursor = adaptor.createCursor(el);
						var root = blok.Root.node({
							target: el,
							child: fromJson(props)
						}).createView();
						root.hydrate(cursor, adaptor, null, null);
						root;
					}
				];
				return blok.DisposableItem.ofCallback(() -> {
					for (island in islands) island.dispose();
				});
			}
			#end

			function __islandName() {
				return islandName;
			}
		});
	}
}
