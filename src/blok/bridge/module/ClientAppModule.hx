package blok.bridge.module;

import blok.bridge.client.*;
import blok.bridge.server.Generator;
import blok.html.server.*;
import capsule.*;

class ClientAppModule implements Module {
	public function new() {}

	public function provide(container:Container) {
		container.map(ClientAppPlugin).to(ClientAppPlugin).share();

		// Add a script tag to the generated HTML so our client app will be loaded.
		container.when(Generator).resolved((config:Config, logger:Logger) -> {
			value.onPageRendered.add((_, document) -> {
				document
					.find(el -> el.as(ElementPrimitive)?.tag == 'body', true)
					.inspect(body -> {
						var script = new ElementPrimitive('script');
						script.setAttribute('src', config.clientSrc);
						script.setAttribute('defer', 'defer');
						body.append(script);
					});
			});
			value;
		});

		container.when(AppPlugins).resolved((client:ClientAppPlugin) -> value.prepend(client));
	}
}
