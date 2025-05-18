package blok.bridge;

import blok.ComponentBuilder;
import haxe.macro.Expr;
import kit.macro.*;
import kit.macro.step.*;

using Lambda;
using haxe.macro.Tools;
using kit.macro.Tools;

function build() {
	return ClassBuilder.fromContext()
		.addBundle(new ComponentBuilder())
		.addBundle(new IslandBuilder())
		.export();
}

final IslandContextSerializeHook = 'islands:context-serialize';
final IslandContextDeserializeHook = 'islands:context-deserialize';

class IslandContextProviderBuildStep implements BuildStep {
	public final priority:Priority = Before;

	public function new() {}

	public function apply(builder:ClassBuilder) {
		for (field in builder.findFieldsByMeta(':context')) {
			parseField(builder, field);
		}
	}

	function parseField(builder:ClassBuilder, field:Field) {
		switch field.kind {
			case FVar(t, _) if (t != null):
				var pos = field.pos;
				var name = field.name;
				var path = switch t {
					case TPath(p):
						p.typePathToArray();
					default:
						field.pos.error('Could not resolve type');
						return;
				}
				var prefix = t.toType().toComplexType().toString();

				builder
					.hook(IslandContextSerializeHook)
					.addExpr(macro @:pos(field.pos) Reflect.setField(__context, $v{name}, this.$name.toJson()));
				builder
					.hook(IslandContextDeserializeHook)
					.addExpr(macro @:pos(field.pos) resolver.resolve(
						$v{prefix},
						Reflect.field(context, $v{name}),
						$p{path}.fromJson
					));
			default:
				// Allow the main ContextFieldBuildStep to handle errors.
		}
	}
}

class IslandBuilder implements BuildBundle implements BuildStep {
	public final priority:Priority = Late;

	public function new() {}

	public function steps():Array<BuildStep> {
		return [
			new IslandContextProviderBuildStep(),
			new JsonSerializerBuildStep({
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
			}),
			this
		];
	}

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
					return switch investigate().findAncestorComponent(blok.bridge.Island) {
						case None:
							blok.bridge.IslandElement.node({
								component: __islandName(),
								props: toJson(),
								context: contextToJson(),
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

		var contextSerializers = builder.hook(IslandContextSerializeHook).getExprs();
		var contextDeserializers = builder.hook(IslandContextDeserializeHook).getExprs();
		var deserializeBody:Expr = if (contextDeserializers.length > 0) {
			var providers = contextDeserializers.map(expr -> macro {
				value: $expr,
				shared: true
			});
			macro {
				var resolver = blok.bridge.IslandContextResolver.current();
				new blok.Provider.ProviderFactory([$a{providers}]).child(child).node();
			}
		} else macro child;

		builder.add(macro class {
			public static final islandName = $v{path};

			#if blok.client
			public static function hydrateIslands(adaptor:blok.engine.Adaptor, ?options):blok.core.Disposable {
				var elements = blok.bridge.IslandElement.getIslandElementsForComponent(islandName, options);
				var islands = [
					for (el in elements) {
						var props:{} = blok.bridge.IslandElement.getIslandProps(el);
						var context:{} = blok.bridge.IslandElement.getIslandContext(el);
						var child = fromJson(props);
						var root = new blok.Root(el, adaptor, $deserializeBody);
						root.hydrate().orThrow();
						root;
					}
				];
				return blok.core.DisposableItem.ofCallback(() -> {
					for (island in islands) island.dispose();
				});
			}
			#else
			function contextToJson() {
				var __context = {};
				@:mergeBlock $b{contextSerializers};
				return __context;
			}
			#end

			function __islandName() {
				return islandName;
			}
		});
	}
}
