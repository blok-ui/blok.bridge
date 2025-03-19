package blok.bridge.module;

import blok.bridge.log.DefaultLogger;
import blok.bridge.server.*;
import capsule.*;
import kit.file.FileSystem;
import kit.file.adaptor.SysAdaptor;

class CoreModule implements Module {
	public function new() {}

	public function provide(container:Container) {
		container.map(AppRunner).to(AppRunner).share();
		container.map(AppPlugins).to(() -> new AppPlugins([])).share();
		container.map(AppProviders).to(() -> new AppProviders([])).share();
		container.map(Logger).toDefault(DefaultLogger).share();
		container.map(FileSystem)
			.toDefault((config:Config) -> new FileSystem(new SysAdaptor(config.rootPath)))
			.share();
		container.map(RenderPageMiddleware).to(RenderPageMiddleware).share();
		container.map(AppMiddleware)
			.to((renderer:RenderPageMiddleware) -> new AppMiddleware([renderer]))
			.share();
		container.map(OutputDirectory)
			.toDefault((fs:FileSystem, config:Config) -> fs.directory(config.outputPath))
			.share();
	}
}
