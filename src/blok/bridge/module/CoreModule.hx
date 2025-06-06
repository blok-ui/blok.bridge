package blok.bridge.module;

import blok.bridge.log.*;
import blok.bridge.server.*;
import capsule.*;
import kit.cli.*;
import kit.cli.sys.*;
import kit.file.FileSystem;
import kit.file.adaptor.SysAdaptor;

class CoreModule implements Module {
	public function new() {}

	public function provide(container:Container) {
		container.map(AppRunner).to(AppRunner).share();
		container.map(AppPlugins).to(() -> new AppPlugins([])).share();
		container.map(AppProviders).to(() -> new AppProviders([])).share();
		container.map(Console).toDefault(SysConsole).share();
		container.map(Logger)
			.toDefault((config:Config, console:Console) -> new DefaultLogger({
				depth: config.logDepth
			}, console))
			.share();
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
