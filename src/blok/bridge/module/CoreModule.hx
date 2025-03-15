package blok.bridge.module;

import blok.bridge.server.*;
import capsule.*;
import kit.file.FileSystem;
import kit.file.adaptor.SysAdaptor;

class CoreModule implements Module {
	final config:Config;
	final render:Render;
	final logger:Logger;

	public function new(config, render, logger) {
		this.config = config;
		this.render = render;
		this.logger = logger;
	}

	public function provide(container:Container) {
		container.map(Config).toDefault(config).share();
		container.map(Render).toDefault(render).share();
		container.map(Logger).toDefault(logger).share();
		container.map(FileSystem)
			.toDefault((config:Config) -> new FileSystem(new SysAdaptor(config.rootPath)))
			.share();
		container.map(BridgeMiddleware).to(BridgeMiddleware).share();
		container.map(MiddlewareStack)
			.to((bridge:BridgeMiddleware) -> new MiddlewareStack([bridge]))
			.share();
		container.map(OutputDirectory)
			.toDefault((fs:FileSystem, config:Config) -> fs.directory(config.outputPath))
			.share();
	}
}
