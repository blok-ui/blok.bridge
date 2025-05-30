package blok.bridge.util;

@:forward
abstract Process(Task<Int>) to Task<Int> {
	public static function registerCloseHandler(close:() -> Void) {
		#if nodejs
		var readline = js.node.Readline.createInterface({
			input: js.Node.process.stdin,
			output: js.Node.process.stdout
		});
		readline.once('close', close);
		#else
		// @todo: implement this.
		throw new haxe.exceptions.NotImplementedException();
		#end
	}

	public function new(cmd:String, args:Array<String>) {
		this = new Task(activate -> {
			#if nodejs
			var process = js.node.ChildProcess.spawn(cmd, args, {shell: true});
			process.stderr.on('data', value -> {
				Sys.println(value);
			});
			process.on('exit', code -> switch code {
				case 0:
					activate(Ok(code));
				case code:
					activate(Error(new Error(InternalError, 'Process closed with code: $code')));
			});
			#else
			var process = new sys.io.Process(cmd + ' ' + args.join(' '));
			switch process.exitCode() {
				case 0:
					activate(Ok(0));
				case code:
					Sys.println(process.stderr.readAll().toString());
					activate(Error(new Error(InternalError, 'Process closed with code: $code')));
			}
			#end
		});
	}
}
