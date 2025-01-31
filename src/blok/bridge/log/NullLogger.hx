package blok.bridge.log;

import blok.bridge.Logger;

class NullLogger implements Logger {
	public function new() {}

	public function log(level:LogLevel, message:String) {
		// noop
	}
}
