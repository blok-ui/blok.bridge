package blok.bridge.plugin;

class Visitor extends Plugin {
	@:value final links:Array<String>;

	public function run() {
		var core = Lifecycle.from(this);
		var generator = Generator.from(this);
		var link = core.setup.add(_ -> {
			for (link in links) generator.visitor.enqueue(link);
		});

		addDisposable(() -> link.cancel());
	}
}
