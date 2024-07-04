package blok.bridge;

import haxe.macro.Expr;
import kit.macro.*;
import kit.macro.step.*;

using kit.macro.Tools;

final factory = new ClassBuilderFactory([
	new ConfigBuilder(),
	new JsonSerializerBuildStep({}),
	new ConstructorBuildStep({})
]);

function build() {
	return factory.fromContext().export();
}

class ConfigBuilder implements BuildStep {
	public final priority:Priority = Normal;

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

				builder.hook(Init)
					.addProp({name: name, type: t, optional: e != null})
					.addExpr(if (e == null) {
						macro this.$name = props.$name;
					} else {
						macro if (props.$name != null) this.$name = props.$name;
					});
			default:
				field.pos.error(':prop fields must be vars');
		}
	}
}
