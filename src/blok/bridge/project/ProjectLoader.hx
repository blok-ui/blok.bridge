package blok.bridge.project;

interface ProjectLoader {
	public function load():Task<Project>;
}
