package blok.bridge.log;

#if (js && !nodejs)
import js.Browser.console;
#end
import blok.bridge.Logger;

class DefaultLogger implements Logger {
	public function new() {}

	public function log(level:LogLevel, message:String) {
		#if (js && !nodejs)
		switch level {
			case Debug:
				#if debug
				console.debug(message);
				#end
			case Error:
				console.error(message);
			case Info:
				console.info(message);
			case Warning:
				console.warn(message);
		}
		#else
		switch level {
			case Debug:
				#if debug
				Sys.println('DEBUG: ' + message);
				#end
			case Error:
				Sys.println('ERROR: ' + message);
			case Info:
				Sys.println('INFO: ' + message);
			case Warning:
				Sys.println('WARNING: ' + message);
		}
		#end
	}
}
