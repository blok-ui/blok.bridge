package blok.bridge.server;

import blok.debug.Debug;
import blok.router.RouteVisitor;
import kit.http.*;
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
			var gatherer = new PageGatherer();
			var handler:Handler = request -> Future.immediate(new Response(NotFound, [], ''));

			visitor.enqueue('/');
			visitor.enqueue('/404.html');

			server
				.serve(handler.into(...middleware.append(gatherer).unwrap()))
				.handle(status -> switch status {
					case Failed(e):
						logger.log(Error, e.message);
					case Running(close):
						logger.log(Info, 'Running a mock server to generate static HTML');

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

						function end() {
							logger.log(Info, 'All pages visited. Closing server...');
							close(success -> {
								if (!success) {
									activate(Error(new Error(InternalError, 'Mock server failed to close. No files will be output.')));
									return;
								}
								logger.log(Info, 'Outputting all visited pages...');

								Task
									.parallel(...gatherer.pages.map(writePage))
									.handle(result -> switch result {
										case Error(error):
											activate(Error(error));
										default:
											logger.log(Info, 'All pages output');
											activate(Ok(gatherer.pages));
									});
							});
						}

						function batch(pages:Array<String>) {
							switch pages {
								// case [] if (visitor.hasPending()):
								// 	batch(visitor.drain());
								case []:
									end();
								case pages:
									var pending = pages.length;
									var link:Null<Cancellable> = null;

									link = server.watch(_ -> {
										if (link == null) {
											error('Server visiting failed');
										}

										pending -= 1;
										if (pending == 0) {
											link?.cancel();
											link = null;
											batch(visitor.drain());
										}
									});

									for (page in pages) {
										server.request(new Request(Get, page, [new HeaderField(Accept, 'text/html')]));
									}
							}
						}

						batch(visitor.drain());
					case Closed:
				});
		});
	}
}

typedef PageEntry = {
	public final path:String;
	public final body:String;
};

class PageGatherer implements Middleware {
	public final pages:Array<PageEntry> = [];

	public function new() {}

	public function apply(handler:Handler):Handler {
		return request -> {
			var type = request.headers.find(Accept).map(header -> header.value).or('text/html');

			if (type != 'text/html') return handler.process(request);

			return handler.process(request).map(response -> {
				var path = request.url.toString().trim().normalize();
				if (path.startsWith('/')) path = path.substr(1);
				var body = response.body.map(body -> body.toString()).or('<html></html>');
				var entry:PageEntry = {path: path, body: body};

				pages.push(entry);

				response;
			});
		};
	}
}
