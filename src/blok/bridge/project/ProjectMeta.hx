package blok.bridge.project;

using Reflect;

enum abstract ProjectLicense(String) from String {
	final GPL;
	final LGPL;
	final BSD;
	final Public;
	final MIT;
	final Apache;
}

class ProjectMeta implements Config {
	@:prop public final name:String;
	@:json(to = value.toString(), from = SemVer.parse(value)) @:prop public final version:SemVer;
	@:prop public final url:String;
	@:prop public final license:ProjectLicense;
	@:prop public final releasenote:String;
	@:prop public final contributors:Array<String>;
	@:prop public final tags:Array<String> = [];
}
