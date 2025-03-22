package blok.bridge.server;

import blok.debug.Debug;
import blok.router.RouteVisitor;
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

class StaticSiteGenerator implements Target {
	final strategy:HtmlGenerationStrategy;
	final config:Config;
	final logger:Logger;
	final visitor:RouteVisitor;
	final output:OutputDirectory;
	final middleware:AppMiddleware;

	public function new(config, strategy, logger, visitor, middleware, output) {
		this.config = config;
		this.strategy = strategy;
		this.logger = logger;
		this.visitor = visitor;
		this.middleware = middleware;
		this.output = output;
	}

	public function run():Task<Nothing> {
		return new Task(activate -> {
			var server = new MockServer();
			var client = new MockClient(server);
			var handler:Handler = request -> Future.immediate(new Response(NotFound, [], ''));

			function visitPage(page:String) {
				var request = new Request(Get, page, [new HeaderField(Accept, 'text/html')]);
				var path = page.trim().normalize();
				if (path.startsWith('/')) path = path.substr(1);
				return client.request(request).next(response -> {
					var body = response.body.toString().or('<html></html>');
					var entry:PageEntry = {path: path, body: body};
					return entry;
				});
			}

			// @todo: clear the target dir before output?
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

				return output.file(path).write(entry.body).next(_ -> {
					logger.log(Info, 'Wrote page: ${path}');
					Task.nothing();
				});
			}

			visitor.enqueue('/');
			visitor.enqueue('/404.html');

			server
				.serve(handler.into(...middleware.unwrap()))
				.handle(status -> switch status {
					case Failed(e):
						logger.log(Error, e.message);
					case Running(close):
						logger.log(Info, 'Running a mock server to generate static HTML');

						function visitPages() {
							var pages = visitor.drain();
							return Task.parallel(...pages.map(visitPage))
								.next(entries -> {
									if (visitor.hasPending()) return visitPages();
									return Task.ok(entries);
								});
						}

						visitPages()
							.handle(result -> switch result {
								case Ok(pages):
									logger.log(Info, 'All pages visited. Closing server...');
									close(success -> {
										if (!success) {
											activate(Error(new Error(InternalError, 'Mock server failed to close. No files will be output.')));
											return;
										}

										logger.log(Info, 'Outputting all visited pages...');

										Task
											.parallel(...pages.map(writePage))
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

typedef PageEntry = {
	public final path:String;
	public final body:String;
};
