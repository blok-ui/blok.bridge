package blok.bridge.plugin;

// @todo: make more generic
class GenerateRobotsTxt implements Plugin {
	public function new() {}

	public function register(bridge:Bridge) {
		bridge.events.outputting.add(event -> {
			var robots = bridge.output
				.file('robots.txt')
				.write(["User-agent: CCBot",
					"Disallow: /",
					"",
					"User-agent: ChatGPT-User",
					"Disallow: /",
					"",
					"User-agent: GPTBot",
					"Disallow: /",
					"",
					"User-agent: Google-Extended",
					"Disallow: /",
					"",
					"User-agent: Omgilibot",
					"Disallow: /",
					"",
					"User-agent: FacebookBot",
					"Disallow: /",
					"",
					"User-agent: *",
					"Disallow: /assets/"
				].join('\n'));

			event.enqueue(robots);
		});
	}
}
