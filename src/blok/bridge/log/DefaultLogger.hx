package blok.bridge.log;

import kit.cli.*;
import blok.bridge.Logger;
import blok.bridge.cli.Spinner;

using kit.cli.StyleTools;

class DefaultLogger implements Logger {
	final output:Output;
	final spinner:Spinner;

	public function new(output) {
		this.output = output;
		this.spinner = new Spinner(output);
	}

	public function startWorking(?message:String) {
		if (message != null) output.writeLn(message.bold().color(Yellow));
		spinner.start();
	}

	public function finishWork(?message:String) {
		spinner.stop();
		if (message != null) output.writeLn(message);
	}

	public function log(level:LogLevel, message:String) {
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

		if (spinner.isRunning()) {
			switch level {
				case Error | Warning | Debug:
					spinner.stop();
					output.writeLn(prefix + ' ' + message);
					spinner.start();
				default:
					spinner.setStatus(prefix + (' ' + message + ' ').color(Black).backgroundColor(White));
			}
		} else {
			output.writeLn(prefix + ' ' + message);
		}
	}
}
