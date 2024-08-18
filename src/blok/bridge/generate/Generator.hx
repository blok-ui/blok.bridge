package blok.bridge.generate;

import hotdish.SemVer;
import blok.context.Provider;
import blok.html.Server;
import blok.html.server.*;
import blok.router.*;
import blok.suspense.SuspenseBoundary;
import blok.ui.*;
import kit.file.*;

using Lambda;

// @todo: Ideally we could do cool things with threads here, but for now...
// @todo: We really need to figure out how configuration is going to work for this thing.
class Generator implements Config {
	@:auto final app:App;
	@:auto final strategy:HtmlGenerationStrategy;
	@:auto final render:() -> Child;

	public function generate():Task<Nothing> {
		var visitor = new RouteVisitor();

		visitor.enqueue('/');

		return renderUntilComplete(visitor)
			.next(documents -> Task.parallel(...documents.map(html -> html.output(strategy, app.output))));
	}

	public function generatePage(path:String):Task<Nothing> {
		var visitor = new RouteVisitor();
		return renderPath(path, visitor).next(document -> document.output(strategy, app.output));
	}

	function renderUntilComplete(visitor:RouteVisitor):Task<Array<GeneratedHtml>> {
		var paths = visitor.drain();
		return Task
			.parallel(...paths.map(path -> renderPath(path, visitor)))
			.next(documents -> {
				if (visitor.hasPending()) {
					return renderUntilComplete(visitor)
						.next(moreDocuments -> documents.concat(moreDocuments));
				}
				return documents;
			});
	}

	function renderPath(path:String, visitor:RouteVisitor):Task<GeneratedHtml> {
		return new Task(activate -> {
			var document = new ElementPrimitive('#document', {});
			var root:Null<View> = null;
			var suspended = false;
			var activated = false;

			function checkActivation() {
				if (activated) throw 'Activated more than once on a render';
				activated = true;
			}

			function sendHtml(path:String, document:ElementPrimitive) {
				var html = document.children.find(el -> el.as(ElementPrimitive)?.tag == 'html') ?? document;
				var head = html.children.find(el -> el.as(ElementPrimitive)?.tag == 'head')?.toString({includeTextMarkers: false}) ?? '<head></head>';
				var body = html.children
					.find(el -> el.as(ElementPrimitive)?.tag == 'body')
					.toMaybe()
					.map(body -> body.as(ElementPrimitive))
					.map(body -> {
						var script = new ElementPrimitive('script', {
							defer: true,
							src: app.paths.clientApp
						});
						body.append(script);
						return body.toString({includeTextMarkers: true});
					})
					.or('<body></body>');
				var output = new GeneratedHtml(path, '<!doctype html><html>${head}${body}</html>');

				root?.dispose();

				activate(Ok(output));
			}

			root = mount(document, () -> Provider
				.provide(() -> visitor)
				.provide(() -> app)
				.provide(() -> new Navigator({
					url: path
				}))
				.child(_ -> SuspenseBoundary.node({
					child: render(),
					onSuspended: () -> suspended = true,
					onComplete: () -> {
						checkActivation();
						sendHtml(path, document);
					},
					fallback: () -> Placeholder.node()
				}))
			);

			if (suspended == false) {
				checkActivation();
				sendHtml(path, document);
			}
		});
	}
}
