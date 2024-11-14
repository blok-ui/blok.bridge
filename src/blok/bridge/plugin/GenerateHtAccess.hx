package blok.bridge.plugin;

import blok.data.Structure;

class GenerateHtAccess extends Structure implements Plugin {
	@:constant final blockAiScrapers:Bool = true;

	public function register(bridge:Bridge) {
		bridge.events.outputting.add(output -> {
			var file = bridge.output.file('.htaccess');

			var htAccess = file.getMeta().next(meta -> {
				output.includeFile(meta.path);
				return file.write([
					'ErrorDocument 404 400.html',
					'<IfModule mod_rewrite.c>',
					'RewriteEngine On',
					if (blockAiScrapers)
						'RewriteCond %{HTTP_USER_AGENT} (CCBot|ChatGPT|GPTBot|Omgilibot|FacebookBot) [NC]'
					else
						null,
					'RewriteRule ^ - [F]',
					'</IfModule>'
				].filter(s -> s != null).join('\n'));
			});

			output.enqueue(htAccess);
		});
	}
}
