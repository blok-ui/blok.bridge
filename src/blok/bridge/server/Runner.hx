package blok.bridge.server;

class Runner {
	final client:ClientBuilder;
	final target:Target;

	public function new(client:ClientBuilder, target:Target) {
		this.client = client;
		this.target = target;
	}

	public function run() {
		return client.build().next(_ -> target.run());
	}
}
