package blok.bridge.cli;

import kit.cli.Output;
import haxe.Timer;

class Spinner {
	final output:Output;
	final frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
	// final frames = ["◐", "◓", "◑", "◒"];
	var status:Null<String>;
	var currentFrame = 0;
	var timer:Null<Timer> = null;

	public function new(output) {
		this.output = output;
	}

	public function start() {
		if (timer != null) stop();
		output.hideCursor();
		timer = new Timer(80);
		timer.run = render;
	}

	public function setStatus(status) {
		this.status = status;
	}

	public function render() {
		currentFrame++;
		if (currentFrame > frames.length - 1) {
			currentFrame = 0;
		}

		var out = frames[currentFrame];
		if (status != null) {
			out += ' ' + status;
		}

		output.clear(out);
	}

	public function stop() {
		if (timer == null) return;
		output.clear();
		output.showCursor();
		currentFrame = 0;
		timer.stop();
		timer = null;
	}

	public function isRunning() {
		return timer != null;
	}
}
