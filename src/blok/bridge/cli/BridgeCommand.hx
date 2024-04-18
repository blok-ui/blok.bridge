package blok.bridge.cli;

import kit.cli.Command;

class BridgeCommand implements Command {
	/**
		Various commands for setting up Bridge-based projects.
	**/
	@:command final setup:SetupCommand;

	/**
		Build a project
	**/
	@:command final build:BuildCommand;

	public function new(setup, build) {
		this.setup = setup;
		this.build = build;
	}

	/**
		Entry-point for Bridge.
	**/
	@:defaultCommand
	function help() {
		output.write(getDocs());
		return 0;
	}
}
