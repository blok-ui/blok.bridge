// THIS IS A GENERATED FILE.
// DO NOT EDIT.

function main() {
	#if !blok.client
	var fs = new kit.file.FileSystem(new kit.file.adaptor.SysAdaptor(Sys.getCwd()));
	var app = new blok.bridge.App({
		fs: fs,
		output: fs.directory("dist/www"),
		version: "0.0.1",
		paths: new blok.bridge.Paths({
			assetPrefix: "assets", 
			clientApp: "/assets/app_v0_0_1.js"
		})
	});
	blok.bridge.Bridge.generate({
		app: app,
		render: () -> blog.Blog.node({}),
		strategy: DirectoryWithIndexHtmlFile
	});
	#end
}
