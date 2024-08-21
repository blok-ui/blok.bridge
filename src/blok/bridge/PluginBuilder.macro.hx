package blok.bridge;

import kit.macro.step.JsonSerializerBuildStep;
import kit.macro.*;

using kit.macro.Tools;

function build() {
	return ClassBuilder.fromContext()
		.addBundle(new ConfigBuilder())
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
