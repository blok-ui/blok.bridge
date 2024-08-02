package blok.bridge;

import haxe.macro.Expr;
import kit.macro.*;
import kit.macro.step.*;

using kit.macro.Tools;

function build() {
	return ClassBuilder.fromContext().use(new ConfigBuilder()).export();
}

class ConfigBuilder implements BuildBundle implements BuildStep {
	public final priority:Priority = Normal;

	public function new() {}

	public function steps():Array<BuildStep> return [
		new JsonSerializerBuildStep({}),
		new ConstructorBuildStep({}),
		this
	];

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
