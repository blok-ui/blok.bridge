package blok.bridge.project;

import haxe.macro.Expr;
import blok.macro.*;
import blok.macro.builder.*;

using blok.macro.MacroTools;

final builderFactory = new ClassBuilderFactory([
	new ConfigBuilder(),
	new JsonSerializerBuilder({}),
	new ConstructorBuilder({})
]);

function build() {
	return builderFactory.fromContext().export();
}

class ConfigBuilder implements Builder {
	public final priority:BuilderPriority = Normal;

	public function new() {}

	public function apply(builder:ClassBuilder) {
		for (field in builder.findFieldsByMeta(':prop')) {
			parsePropField(builder, field);
		}

		switch builder.findField('dispose') {
			case Some(_):
			case None:
				builder.add(macro class {
					public function dispose() {}
				});
		}
	}

	function parsePropField(builder:ClassBuilder, field:Field) {
		switch field.kind {
			case FVar(t, e):
				var name = field.name;

				builder.addProp('new', {name: name, type: t, optional: e != null});
				builder.addHook('init', if (e == null) {
					macro this.$name = props.$name;
				} else {
					macro if (props.$name != null) this.$name = props.$name;
				});
			default:
				field.pos.error(':prop fields must be vars');
		}
	}
}
