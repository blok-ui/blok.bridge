package blok.bridge;

import kit.macro.*;
import kit.macro.step.*;
import blok.ui.ComponentBuilder;

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
					var child:() -> blok.ui.Child = () -> $render;
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
			public static function hydrateIslands(adaptor:blok.adaptor.Adaptor) {
				var elements = blok.bridge.IslandElement.getIslandElementsForComponent(islandName);
				return [
					for (el in elements) {
						var props:{} = blok.bridge.IslandElement.getIslandProps(el);
						var cursor = adaptor.createCursor(el);
						var root = blok.ui.Root.node({
							target: el,
							child: () -> fromJson(props)
						}).createView();
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
