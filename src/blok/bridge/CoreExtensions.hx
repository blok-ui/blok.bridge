package blok.bridge;

import blok.bridge.Constants;
import blok.bridge.log.DefaultLogger;
import blok.bridge.util.Sources;
import blok.context.Provider;
import blok.data.Object;
import blok.html.server.*;
import kit.file.Directory;

using StringTools;
using blok.bridge.util.Commands;
using haxe.io.Path;

function useDefaults():Extension {
	return [
		generateStaticHtml(DirectoryWithIndexHtmlFile),
		generateClientApp({dependencies: InheritDependencies}),
		visitNotFoundPage(),
		useLogging()
	];
}

enum abstract HtmlGenerationStrategy(String) to String from String {
	final DirectoryWithIndexHtmlFile;
	final NamedHtmlFile;
}

typedef OutputHtmlEntry = {
	public final path:String;
	public final document:NodePrimitive;
}

function generateStaticHtml(strategy:HtmlGenerationStrategy):Extension {
	return bridge -> {
		final entries:Array<OutputHtmlEntry> = [];

		bridge.events.renderComplete.add(rendered -> {
			var path = rendered.path.trim().normalize();
			if (path.startsWith('/')) path = path.substr(1);
			entries.push({path: path, document: rendered.document});
		});

		bridge.events.outputting.add(output -> output.enqueue(
			Task.parallel(...entries.map(entry -> {
				var head = entry.document
					.find(el -> el.as(ElementPrimitive)?.tag == 'head', true)
					.or(() -> new ElementPrimitive('head'));
				var body = entry.document
					.find(el -> el.as(ElementPrimitive)?.tag == 'body', true)
					.or(() -> new ElementPrimitive('body'));
				var html = '<!doctype html><html>${head.toString({ includeTextMarkers: false })}${body.toString()}</html>';

				var file = switch strategy {
					case DirectoryWithIndexHtmlFile:
						bridge.output.file(if (entry.path.extension() == '') {
							Path.join([entry.path, 'index.html']);
						} else {
							entry.path;
						});
					case NamedHtmlFile if (entry.path == ''):
						bridge.output.file('index.html');
					case NamedHtmlFile:
						bridge.output.file(entry.path.withExtension('html'));
				}

				file.write(html)
					.next(_ -> file.getMeta())
					.next(meta -> {
						output.includeFile(meta.path);
						Task.nothing();
					});
			}))
		));

		bridge.events.cleanup.add(cleanup -> {
			cleanup.addDisposable(() -> entries.resize(0));
		});
	};
}

enum ClientAppDependencies {
	InheritDependencies;
	UseHxml(path:String);
	UseCustom(deps:Array<{name:String, ?version:String}>);
}

enum ClientAppNamingStrategy {
	UseAppVersion(prefix:String);
	UseName(name:String);
}

private class ClientAppConfig extends Object {
	@:value public final main:String = 'BridgeIslands';
	@:value public final sources:Array<String> = ['src'];
	@:value public final namingStrategy:ClientAppNamingStrategy = UseName('assets/app');
	@:value public final dependencies:ClientAppDependencies = InheritDependencies;
	@:value public final flags:Array<String> = [];
	@:value public final minify:Bool = false;

	public function getAppName(bridge:Bridge) {
		return (switch namingStrategy {
			case UseName(name):
				'/' + name.withExtension('js');
			case UseAppVersion(prefix):
				'/' + prefix + '_' + bridge.version.toFileNameSafeString().withExtension('js');
		}).normalize();
	}

	public function createHaxeCommand(bridge:Bridge) {
		var sources:Array<String> = sources.concat([DotBridge]);
		var cmd = ['haxe'.createNodeCommand()];
		var libraries = ['blok.bridge'];
		var flags = this.flags.copy();

		switch dependencies {
			case InheritDependencies:
				var paths = Sources.getCurrentClassPaths().filter(path -> path != '' && path != null);
				sources = sources.concat(paths);
			case UseHxml(path):
				cmd.push(path.withExtension('hxml'));
			case UseCustom(deps):
				for (lib in deps) {
					libraries.push(lib.name);
				}
		}

		for (lib in libraries) {
			cmd.push('-lib $lib');
		}

		for (path in sources) {
			cmd.push('-cp $path');
		}

		cmd.push('-D js-es=6');
		cmd.push('-D message-reporting=pretty');

		#if debug
		cmd.push('--debug');
		#else
		cmd.push('--dce full');
		cmd.push('-D analyzer-optimize');
		#end

		for (flag in flags) {
			cmd.push(flag);
		}

		var target = Path.join([
			bridge.outputPath,
			getAppName(bridge)
		]).withExtension('js');

		cmd.push('-D blok.client');
		cmd.push('-main ${main}');
		cmd.push('-js ${target}');

		return cmd.join(' ');
	}
}

function generateClientApp(options):Extension {
	var config = new ClientAppConfig(options);
	return bridge -> {
		var appName = config.getAppName(bridge);

		bridge.use(linkAssets([
			JsAsset((switch config.minify {
				case true: appName.withExtension('.min.js');
				default: appName;
			}) + '?${bridge.version.toFileNameSafeString()}'),
			#if debug
			TrackedFile(appName + '.map')
			#end
		]));

		bridge.events.outputting.add(event -> {
			var mainPath = Path.join([DotBridge, config.main]).withExtension('hx');
			var createMain = bridge.fs.file(mainPath).write('// THIS IS A GENERATED FILE.
// DO NOT EDIT.
function main() {
  #if blok.client
	blok.bridge.Bridge.hydrateIslands();
  #end
}');
			event.enqueue(createMain.next(_ -> switch Sys.command(config.createHaxeCommand(bridge)) {
				case 0: Nothing;
				case _: new Error(InternalError, 'Failed to generate haxe file');
			}));

			// @todo: need a minify command!
		});
	}
}

enum Asset {
	TrackedFile(path:String);
	CssAsset(path:String);
	JsAsset(path:String);
	InlineJs(contents:String, ?defer:Bool);
}

function linkAssets(assets:Array<Asset>):Extension {
	return bridge -> {
		bridge.events.renderComplete.add(event -> {
			var head = event.document
				.find(el -> el.as(ElementPrimitive)?.tag == 'head', true)
				.or(() -> new ElementPrimitive('head'));

			for (asset in assets) switch asset {
				case TrackedFile(_):
					// ignore
				case CssAsset(path):
					head.append(new ElementPrimitive('link', {
						href: path.normalize(),
						type: 'text/css',
						rel: 'stylesheet'
					}));
				case JsAsset(path):
					head.append(new ElementPrimitive('script', {
						defer: true,
						src: path.normalize()
					}));
				case InlineJs(contents, defer):
					var script = new ElementPrimitive('script', {
						defer: defer == true
					});
					script.append(new UnescapedTextPrimitive(contents));
					head.append(script);
			}
		});

		bridge.events.outputting.add(event -> {
			event.enqueue(bridge.output.getMeta().next(meta -> {
				for (asset in assets) switch asset {
					case CssAsset(path) | JsAsset(path) | TrackedFile(path):
						var url = path.split('?')[0];
						event.includeFile(Path.join([meta.path, url]).normalize());
					default:
				}
				Task.nothing();
			}));
		});
	}
}

function useLogging(?logger:Logger):Extension {
	if (logger == null) logger = new DefaultLogger();
	return bridge -> {
		bridge.events.rendering.add(event -> {
			event.apply(child -> Provider
				.share(new LoggerContext(logger))
				.child(child)
			);
		});

		bridge.events.init.add(event -> switch event.mode {
			case GeneratingFullSite:
				logger.log(Info, 'Generating full site');
			case GeneratingSinglePage(path):
				logger.log(Info, 'Generating single page: $path');
		});

		bridge.events.visited.add(path -> logger.log(Info, 'Visiting $path'));

		bridge.events.renderSuspended.add((path, _) -> logger.log(Info, 'Suspended on $path'));

		bridge.events.renderComplete.add(event -> logger.log(Info, 'Completed ${event.path}'));

		bridge.events.renderFailed.add(exception -> logger.log(Error, exception.toString()));

		bridge.events.cleanup.add(event -> logger.log(Info, [
			'Generation complete. Output:'
		].concat(event.getManifest()).join('\n')));
	}
}

function visitLinks(links:Array<String>):Extension {
	return bridge -> {
		bridge.events.init.add(init -> {
			switch init.mode {
				case GeneratingFullSite:
					for (link in links) init.visit(link);
				default:
			}
		});
	}
}

function visitNotFoundPage():Extension {
	return visitLinks(['/404.html']);
}

function outputFile(path:String, content:String):Extension {
	return bridge -> {
		bridge.events.outputting.add(output -> {
			var file = bridge.output.file(path);
			output.enqueue(file.getMeta().next(meta -> {
				output.includeFile(meta.path);
				file.write(content);
			}));
		});
	}
}

function outputHtAccess(?options:{
	?blockAiScrapers:Bool
}):Extension {
	var content = [
		'ErrorDocument 404 400.html',
		'<IfModule mod_rewrite.c>',
		'RewriteEngine On',
		if (options?.blockAiScrapers == true)
			'RewriteCond %{HTTP_USER_AGENT} (CCBot|ChatGPT|GPTBot|Omgilibot|FacebookBot) [NC]'
		else
			null,
		'RewriteRule ^ - [F]',
		'</IfModule>'
	].filter(s -> s != null).join('\n');

	return outputFile('.htaccess', content);
}

function outputRobotsTxt():Extension {
	var content = ["User-agent: CCBot",
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
	].join('\n');

	return outputFile('robots.txt', content);
}

function cleanupUnusedFiles():Extension {
	return bridge -> {
		bridge.events.cleanup.add(event -> {
			event.enqueue(cleanupDir(bridge.output, event.getManifest()));
		});
	}
}

private function cleanupDir(dir:Directory, manifest:Array<String>) {
	return dir
		.listFiles()
		.next(files -> {
			if (files.length == 0) return Task.nothing();

			Task.parallel(...files.map(file -> file
				.getMeta()
				.next(meta -> if (!manifest.contains(meta.path)) {
					trace('REMOVE: ${meta.path}');
					// file.remove(); // @todo: We're turning this off until I'm more sure about this
					Task.nothing();
				} else {
					Task.nothing();
				})
			));
		})
		.next(_ -> dir
			.listDirectories()
			.next(dirs -> {
				if (dirs.length == 0) return Task.nothing();

				Task.parallel(...dirs.map(dir -> cleanupDir(dir, manifest)));
			})
		)
		.next(_ -> Task.nothing());
}
