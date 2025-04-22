package blok.bridge;

enum abstract LogLevel(Int) to Int {
	final Debug = 0;
	final Warning = 1;
	final Error = 2;
	final Info = 3;
}

typedef LoggerOptions = {
	public final depth:LogLevel;
}

interface Logger {
	public function log(level:LogLevel, message:String):Void;
	public function work(handler:() -> Task<Nothing>):Task<Nothing>;
}
