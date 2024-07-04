package blok.bridge;

import blok.ui.Child;

abstract class Bootstrap {
	public final function new() {}

	abstract public function start():Child;

	// @todo: Come up with better defaults for this;
	public function finish(result:Result<AppContext>) {
		switch result {
			case Ok(context):
			// todo
			case Error(error):
				trace(error.message);
		}
	}
}
