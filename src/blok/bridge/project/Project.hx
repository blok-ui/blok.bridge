package blok.bridge.project;

interface Project {
	public final project:ProjectMeta;
	public final paths:ProjectPaths;
	public final server:ProjectTarget;
	public final client:ProjectTarget;
	public function getBuildFlagsForServer():Array<String>;
	public function getBuildFlagsForClient():Array<String>;
	public function createServerHxml():String;
	public function createHaxelibJson():String;
}
