package blok;

import blok.bridge.*;
import blok.bridge.cli.*;
import blok.bridge.project.loader.*;
import kit.file.FileSystem;
import kit.file.adaptor.SysAdaptor;

using kit.Cli;

function main() {
	var fs = new FileSystem(new SysAdaptor(Sys.getCwd()));
	var loader = new TomlProjectLoader(fs, BridgeProject.fromJson);
	var setup = new SetupCommand(fs, loader);
	var build = new BuildCommand(loader);
	var cli = new BridgeCommand(setup, build);
	Cli.fromSys().execute(cli);
}
