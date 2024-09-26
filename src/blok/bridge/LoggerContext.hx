package blok.bridge;

import blok.bridge.log.DefaultLogger;
import blok.bridge.Logger;
import blok.context.Context;

@:fallback(new LoggerContext(new DefaultLogger()))
class LoggerContext implements Context implements Logger {
	final logger:Logger;

	public function new(logger) {
		this.logger = logger;
	}

	public function dispose() {}

	public function log(level:LogLevel, message:String) {
		logger.log(level, message);
	}
}
