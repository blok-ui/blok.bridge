package blok.bridge;

import blok.bridge.log.DefaultLogger;
import blok.bridge.Logger;

@:fallback(new LoggerContext(new DefaultLogger()))
class LoggerContext implements Context implements Logger {
	final logger:Logger;

	public function new(logger) {
		this.logger = logger;
	}

	public function log(level:LogLevel, message:String) {
		logger.log(level, message);
	}

	public function dispose() {}
}
