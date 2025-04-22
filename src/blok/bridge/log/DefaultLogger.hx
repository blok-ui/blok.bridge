package blok.bridge.log;

import kit.cli.*;
import blok.bridge.Logger;

using kit.cli.StyleTools;
using kit.cli.display.TaskTools;

class DefaultLogger implements Logger {
	final options:LoggerOptions;
	var console:Console;

	public function new(options, console) {
		this.options = options;
		this.console = console;
	}

	public function log(level:LogLevel, message:String) {
		if ((options.depth : Int) > (level : Int)) return;

		var prefix = switch level {
			case Debug:
				' DEBUG '.backgroundColor(Cyan).bold();
			case Info:
				' INFO '.backgroundColor(Blue).bold();
			case Error:
				' ERROR '.backgroundColor(Red).bold();
			case Warning:
				' WARNING '.backgroundColor(Yellow).bold();
		}

		console.writeLine(prefix + ' ' + message);
	}

	public function work(handler:() -> Task<Nothing>):Task<Nothing> {
		var currentConsole = this.console;
		return console.runTask(console -> {
			this.console = console;
			handler().then(_ -> {
				this.console = currentConsole;
				0;
			});
		});
	}
}
