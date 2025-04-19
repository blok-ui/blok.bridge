import blok.bridge.*;
import blok.bridge.module.*;
import spa.Scaffold;

function main() {
	var app = new App<ClientAppModule, StaticSiteGeneratorModule>({
		version: '0.0.1',
		outputPath: 'dist/spa/www',
		clientDependencies: UseHxml('spa-client.hxml'),
		clientMinified: false,
	}, () -> Scaffold.node({}));

	app.run();
}
