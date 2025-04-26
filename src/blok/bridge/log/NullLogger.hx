package blok.bridge.log;

import blok.bridge.Logger;

class NullLogger implements Logger {
	public function new() {}

	public function log(level:LogLevel, message:String) {
		// noop
	}

	public function startWorking(?message:String) {
		// noop
	}

	public function finishWork(?message:String) {
		// noop
	}

	public function work(handler:() -> Task<Nothing, Error>):Task<Nothing, Error> {
		return handler();
	}
}
