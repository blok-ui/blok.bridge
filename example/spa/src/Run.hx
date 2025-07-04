import blok.bridge.*;
import blok.bridge.module.*;
import spa.Scaffold;

function main() {
	var app = new App<ClientAppModule, StaticSiteGeneratorModule>({
		outputPath: 'dist/spa/www',
		clientDependencies: UseHxml('spa-client.hxml'),
		clientMinified: false,
	}, () -> Scaffold.node({}));

	app.run();
}
