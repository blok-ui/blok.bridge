package blok.bridge;

import blok.bridge.BridgeProject;

class Bridge {
	public static function start(render, ?fs) {
		var embed = BridgeProject.embed();
		return macro new blok.bridge.Bridge($embed, $render, ${fs ?? macro null});
	}
}
