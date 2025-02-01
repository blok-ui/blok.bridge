package blok.bridge.plugin;

import blok.bridge.util.TaskQueue;

// Note: Making this work will require a much more comprehensive overhaul
// of the Plugin system. Probably what we should do is run *everything* through
// a Server and just use a mocked up one for Static sites.`kit.http` should have this
// power.
//
// I think this closes our Plugin experiment though -- we need a better solution, and
// that will probably be done best using Server middleware.
class ServeHtml extends Plugin {
	public final closed:Event = new Event();

	public function run() {
		var generator = Generator.from(this);
		var output = Output.from(this);
		var lifecycle = Lifecycle.from(this);

		// pseudo code:
		lifecycle.serve.add(queue -> {
			var task = new Task(activate -> server
				.serve(request -> {
					generator.renderSinglePage(request.url.toString())
						.next(document -> {
							// handle any file writing we need to do:
							var tasks = new TaskQueue();
							output.exporting.dispatch(tasks);
							return tasks.parallel()
								.next(_ -> new Response(OK, [
									new HeaderField(ContentType, 'text/html'),
								], document.toString()));
						});
				})
				.handle(status -> switch status {
					case Failed(e):
						activate(Error(e));
					case Running(close):
						closed.add(() -> {
							close();
							activate(Ok(Nothing));
						});
					case Closed:
						activate(Ok(Nothing));
				})
			);
			queue.enqueue(task);
		});
	}
}
