package blok.bridge.server;

import blok.bridge.server.StaticSiteGenerator;

class StaticSiteGeneratorEvents {
	public final visiting = new Event<String>();
	public final renderedPage = new Event<PageEntry>();
	public final renderedSite = new Event<Array<PageEntry>>();

	public function new() {}
}
