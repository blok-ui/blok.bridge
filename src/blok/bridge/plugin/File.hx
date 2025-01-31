package blok.bridge.plugin;

class File extends Plugin {
	@:value final path:String;
	@:value final content:String;

	public function run() {
		Output
			.maybeFrom(this)
			.inspect(output -> output.write(path, content));
	}
}
