package blok.bridge;

import blok.bridge.Logger.LogLevel;
import blok.bridge.util.SemVer;
import blok.data.Object;

using haxe.io.Path;

class CustomClientAppConfig extends Object {
	/**
		Tell the Haxe compiler where to find sources for the client-side app. Defaults to `['src']`.
	**/
	@:value public final sources:Array<String> = ['src'];

	/**
		Define dependencies for the client-side app. Note that `blok.bridge` will be included for
		you automatically.
	**/
	@:value public final deps:Array<{name:String, ?version:String}> = [];

	/**
		Define any flags you want to have present on the client app. Note that `--debug` is automatically
		inherited from the sever-side app, and that the `blok.client` flag will automatically be set
		to `true` for you.
	**/
	@:value public final flags:Array<String> = [];
}

enum ClientAppDependencies {
	InheritDependencies;
	UseHxml(path:String);
	UseCustom(config:CustomClientAppConfig);
}

class Config extends Object {
	/**
		Set how many logger messages you see.
	**/
	@:value public final logDepth:LogLevel = #if debug Debug #else Warning #end;

	/**
		The root path all other paths will be relative to. Defaults to the
		current working directory.
	**/
	@:value public final rootPath:String = Sys.getCwd();

	/**
		The folder all generated files will be saved to, relative to `rootPath`.
		This should never be an absolute path.

		Defaults to `'dist/www'`.
	**/
	@:value public final outputPath:String = 'dist/www';

	/**
		The path all static assets will be saved to and served from. When being used to write
		files, this is relative to `outputPath`. When serving them it's relative to your app's domain.

		This should never be an absolute path.

		Defaults to `'/assets'`.
	**/
	@:value public final assetsPath:String = '/assets';

	/**
		The path to the client-side app, relative to `outputPath`. Does not 
		need to include a file extension.

		Note that you should use `clientPath` to get the final, fully resolved path.

		Defaults to `'/assets/app'`.
	**/
	@:value public final clientName:String = '/assets/app';

	/**
		Flag to check if the client app should be minified at build time or not. By default,
		this will be true if the compiler is in debug mode and false otherwise.
	**/
	@:value public final clientMinified:Bool = #if debug false #else true #end;

	/**
		Resolve the final path to the client app. This will take into account if `clientMinified` is
		set and use the appropriate extension.

		Note that the `blok.bridge.module.ClientAppModule` will automatically insert a script tag to load
		the client-side app, you do not need to add it yourself.
	**/
	@:prop(get = switch clientMinified {
			case true: clientName.withExtension('min.js');
			case false: clientName.withExtension('js');
		}) public final clientPath:String;

	/**
		Configure the way the client app's dependencies are resolved.

		Available options are:

		#### InheritDependencies

		This is the simplest but by far the most error-prone option. The compiler will
		try to use the same class paths used to compile the server side app to compile the client-side one.
		This *can* work, but often results in very strange bugs, including otherwise inexplicable
		runtime errors. Use with caution -- this is only really suitable for quick tests.

		#### UseCustom(config)

		Programmatically configure the client app.

		#### UseHxml(path)

		Use a hxml file to configure the client app. This is *by far* the recommended approach.

		Best practice is to have three hxml files (replace "{appName}" with your app's name):

		- `{appName}-shared.hxml`: Contains configuration and dependencies shared by both sides of your app.
			This *must not* include a `-main` option *or* any output options (like `-js app.js`). Note that
			Bridge will not include this file for you -- this is just a convention, so you'll need to include
			it at the top of your other hxml files manually.
		- `{appName}-server.hxml`: Contains configuration only for the server-side of the app. This
			is also the file you should point your IDE at. This *should* be where you have a `-main` option
			and any output options (or `--run`, depending on your needs).
		- `{appName}-client.hxml`: Contains configuration only for the client-side. This *must not*
			include a `-main` option or any output options, as Bridge needs to handle those. Including them
			will cause the things to fail whenever you build your app.

		Note that this is just a recommendation and not something enforced (or required) by Bridge, other than
		the notes that the client-side hxml file must not define `-main` or any compile targets.
	**/
	@:value public final clientDependencies:ClientAppDependencies;
}
