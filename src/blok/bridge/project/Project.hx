package blok.bridge.project;

interface Project {
	public function getMeta():ProjectMeta;
	public function getPaths():ProjectPaths;
	public function getServerTarget():ProjectTarget;
	public function getClientTarget():ProjectTarget;
	public function getBuildFlagsForServer():Array<String>;
	public function getBuildFlagsForClient():Array<String>;
	public function createServerHxml():String;
	public function createHaxelibJson():String;
}
