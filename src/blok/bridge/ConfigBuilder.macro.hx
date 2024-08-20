package blok.bridge;

import kit.macro.*;
import kit.macro.step.*;

using kit.macro.Tools;

function build() {
	return ClassBuilder.fromContext()
		.addBundle(new ConfigBuilder())
		.export();
}

function buildWithJsonSerializer() {
	return ClassBuilder.fromContext()
		.addBundle(new ConfigBuilder())
		.addStep(new JsonSerializerBuildStep({}))
		.export();
}

class ConfigBuilder implements BuildBundle implements BuildStep {
	public final priority:Priority = Normal;

	public function new() {}

	public function steps():Array<BuildStep> return [
		new AutoInitializedFieldBuildStep({meta: 'auto'}),
		new ConstructorBuildStep({}),
		new PropertyBuildStep(),
		this
	];

	public function apply(builder:ClassBuilder) {
		switch builder.findField('dispose') {
			case Some(_):
			case None:
				builder.add(macro class {
					public function dispose() {}
				});
		}
	}
}
