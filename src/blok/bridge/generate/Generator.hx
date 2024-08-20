package blok.bridge.generate;

import blok.context.Provider;
import blok.html.Server;
import blok.html.server.*;
import blok.router.*;
import blok.suspense.SuspenseBoundary;
import blok.ui.*;

using Lambda;

// @todo: Ideally we could do cool things with threads here, but for now...
class Generator implements Config {
	@:auto final app:App;
	@:auto final strategy:HtmlGenerationStrategy;
	@:auto final render:() -> Child;
	@:auto final links:Array<AssetLink> = [];

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
			var localLinks = links.copy();
			var document = new ElementPrimitive('#document', {});
			var root:Null<View> = null;
			var suspended = false;
			var activated = false;

			localLinks.push(ScriptLink(app.paths.clientApp));

			function checkActivation() {
				if (activated) throw 'Activated more than once on a render';
				activated = true;
			}

			function sendHtml(path:String, document:ElementPrimitive) {
				var html = document.children.find(el -> el.as(ElementPrimitive)?.tag == 'html') ?? document;
				var head = html.children.find(el -> el.as(ElementPrimitive)?.tag == 'head') ?? new ElementPrimitive('head');
				var body = html.children.find(el -> el.as(ElementPrimitive)?.tag == 'body') ?? new ElementPrimitive('body');

				applyLinks(cast head, cast body, localLinks);

				var output = new GeneratedHtml(path, '<!doctype html><html>${head.toString({ includeTextMarkers: false })}${body.toString()}</html>');

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

	function applyLinks(head:ElementPrimitive, body:ElementPrimitive, links:Array<AssetLink>) {
		for (link in links) switch link {
			case CssLink(path):
				head.append(new ElementPrimitive('link', {
					href: path,
					rel: 'stylesheet'
				}));
			case ScriptLink(path):
				body.append(new ElementPrimitive('script', {
					defer: true,
					src: path
				}));
		}
	}
}
