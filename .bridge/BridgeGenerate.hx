// THIS IS A GENERATED FILE.
// DO NOT EDIT.
function main() {
	#if !blok.client
	var fs = new kit.file.FileSystem(new kit.file.adaptor.SysAdaptor(Sys.getCwd()));
	var app = new blok.bridge.App({
		fs: fs,
		output: fs.directory("dist/www"),
		version: "0.0.1"
	});
	blok.bridge.Bridge.generate(app, () -> blog.Blog.node({}), [
		blok.bridge.plugin.LinkAssets.fromJson({"links":[{"path":"/assets/styles-v0_0_1.css","type":"CssLink"}]}),
    new blok.bridge.plugin.IncludeClientApp({src: "/assets/app-v0_0_1.js", minify: false}),
    new blok.bridge.plugin.OutputHtml({strategy: DirectoryWithIndexHtmlFile})
	]);
	#end
}
