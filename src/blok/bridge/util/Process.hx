package blok.bridge.util;

#if nodejs
import js.node.ChildProcess;
#end

class Process {
	public static function registerCloseHandler(close:() -> Void) {
		#if nodejs
		var readline = js.node.Readline.createInterface({
			input: js.Node.process.stdin,
			output: js.Node.process.stdout
		});
		readline.once('close', close);
		#else
		throw new haxe.exceptions.NotImplementedException();
		#end
	}

	final task:Task<Int>;

	public function new(cmd:String, args:Array<String>) {
		task = new Task(activate -> {
			#if nodejs
			var process = ChildProcess.spawn(cmd, args);
			process.on('exit', (code, _) -> {
				activate(Ok(code));
			});
			#else
			var process = new sys.io.Process(cmd, args);
			activate(Ok(process.exitCode()));
			#end
		});
	}

	public inline function getTask() {
		return task;
	}
}
