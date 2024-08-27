package blok.bridge;

import blok.data.StructureBuilder;
import kit.macro.*;
import kit.macro.step.JsonSerializerBuildStep;

using kit.macro.Tools;

function build() {
	return ClassBuilder.fromContext()
		.addBundle(new StructureBuilder())
		.addStep(new JsonSerializerBuildStep({}))
		.addStep(new PluginBuilder())
		.export();
}

class PluginBuilder implements BuildStep {
	public final priority:Priority = Late;

	public function new() {}

	public function apply(builder:ClassBuilder) {
		var name = builder.getTypePath().typePathToString();

		builder.add(macro class {
			public function getPluginIdentifier() {
				return $v{name};
			}
		});
	}
}
