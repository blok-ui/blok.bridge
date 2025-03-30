import blok.bridge.server.*;

using kit.Testing;

function main() {
	Runner.fromDefaults('Blok Bridge')
		.add(GeneratorSuite)
		.run();
}
