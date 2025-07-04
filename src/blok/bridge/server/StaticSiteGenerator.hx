package blok.bridge.server;

import blok.debug.Debug;
import blok.html.server.*;
import kit.http.*;
import kit.http.client.MockClient;
import kit.http.server.MockServer;

using Lambda;
using StringTools;
using haxe.io.Path;

enum abstract HtmlGenerationStrategy(String) to String from String {
	final DirectoryWithIndexHtmlFile;
	final NamedHtmlFile;
}

typedef PageEntry = {
	public final path:String;
	public final body:String;
};

class StaticSiteGenerator implements Target {
	final strategy:HtmlGenerationStrategy;
	final config:Config;
	final logger:Logger;
	final generator:Generator;
	final output:OutputDirectory;
	final middleware:AppMiddleware;

	public function new(config, strategy, logger, generator, middleware, output) {
		this.config = config;
		this.strategy = strategy;
		this.logger = logger;
		this.generator = generator;
		this.middleware = middleware;
		this.output = output;
	}

	public function run():Task<Nothing> {
		return new Task(activate -> {
			var server = new MockServer();
			var client = new MockClient(server);
			var handler:Handler = request -> Future.immediate(new Response(NotFound, [], ''));
			var paths:Array<String> = [];
			var visited:Array<String> = [];

			function isVisitablePath(path:String) {
				// @todo: We probably need a much more robust strategy to figure out if this is a
				// local path we should visit, but this is a start:
				return switch path.extension() {
					case '' | 'html': path.startsWith('/') && !paths.contains(path) && !visited.contains(path);
					default: false;
				}
			}

			function scrapePathsToVisit(node:NodePrimitive) {
				if (node is ElementPrimitive) {
					var el = node.as(ElementPrimitive);
					if (el?.tag == 'a') switch (el?.getAttribute('href') : Null<String>) {
						case null:
						case path if (isVisitablePath(path)):
							paths.push(path);
						default:
					}
				}

				for (node in node.children) {
					scrapePathsToVisit(node);
				}
			}

			function drainPaths() {
				var drained = paths.copy();
				paths = [];
				return drained;
			}

			function visitPage(page:String) {
				if (visited.contains(page)) return Task.error(new Error(InternalError, 'Already visited $page'));

				visited.push(page);

				var request = new Request(Get, page, [new HeaderField(Accept, 'text/html')]);
				var path = page.trim().normalize();
				if (path.startsWith('/')) path = path.substr(1);
				return client.request(request).then(response -> {
					var body = response.body.toString().or('<html></html>');
					var entry:PageEntry = {path: path, body: body};
					return entry;
				});
			}

			function visitPagesRecursively(pages:Array<String>):Task<Array<PageEntry>> {
				return pages
					.map(visitPage)
					.inParallel()
					.then(entries -> {
						var paths = drainPaths().filter(path -> !visited.contains(path));
						if (paths.length > 0) {
							return visitPagesRecursively(paths)
								.then(newEntries -> Task.ok(entries.concat(newEntries)));
						}
						return Task.ok(entries);
					});
			}

			function writePage(entry:PageEntry):Task<Nothing> {
				var path = switch strategy {
					case DirectoryWithIndexHtmlFile:
						if (entry.path.extension() == '') {
							Path.join([entry.path, 'index.html']);
						} else {
							entry.path;
						};
					case NamedHtmlFile if (entry.path == ''):
						'index.html';
					case NamedHtmlFile:
						entry.path.withExtension('html');
				}

				return output.file(path).write(entry.body).then(_ -> {
					logger.log(Info, 'Wrote page: ${path}');
					Task.nothing();
				});
			}

			// Hook into the generator and scrape the primitive tree for paths to visit.
			// We need to do this here as our server will return a string.
			var link = generator.onPageRendered.add((_, primitive) -> scrapePathsToVisit(primitive));

			server
				.serve(handler.into(...middleware.unwrap()))
				.handle(status -> switch status {
					case Failed(e):
						logger.log(Error, e.message);
					case Running(close):
						logger.log(Info, 'Running a mock server to generate static HTML');

						visitPagesRecursively(['/', '/404.html'])
							.always(() -> link.cancel())
							.handle(result -> switch result {
								case Ok(pages):
									logger.log(Info, 'All pages visited. Closing server...');
									close(success -> {
										if (!success) {
											activate(Error(new Error(InternalError, 'Mock server failed to close. No files will be output.')));
											return;
										}

										logger.log(Info, 'Outputting all visited pages...');

										pages
											.map(writePage)
											.inParallel()
											.handle(result -> switch result {
												case Error(error):
													activate(Error(error));
												default:
													logger.log(Info, 'All pages output');
													activate(Ok(pages));
											});
									});
								case Error(error):
									logger.log(Error, error.toString());
									activate(Error(error));
							});

					case Closed:
				});
		});
	}
}
