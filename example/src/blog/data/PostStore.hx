package blog.data;

import boxup.reporter.VisualReporter;
import boxup.*;
import blok.context.Context;
import blok.debug.Debug;
import kit.file.*;

using StringTools;
using haxe.io.Path;

enum MarkdownResult {
	Ok(frontMatter:Dynamic, body:String);
	Error(error:Error);
}

// Note: in a real app, we'd cache these results somehow as
// we'll inevitably use them more than once during rendering.

@:fallback(error('No PostStore found'))
class PostStore implements Context {
	final dir:Directory;

	public function new(dir) {
		this.dir = dir;
	}

	public function all():Task<Array<Post>> {
		return dir.listFiles()
			.next(files -> Task.parallel(...files.map(file -> file.getMeta())))
			.next(metas -> metas.filter(meta -> meta.path.extension() == 'box'))
			.next(metas -> Task.parallel(...metas.map(meta -> get(meta.name))));
	}

	public function get(id:String):Task<Post> {
		return dir.file(id.withExtension('box')).getMeta().next(meta -> {
			dir.file(id.withExtension('box'))
				.read()
				.next(contents -> parse({file: meta.fullPath, content: contents}));
		});
	}

	function parse(source:Source) {
		return Parser.fromSource(source)
			.parse()
			.flatMap(new PostDecoder().decode)
			.mapError(e -> {
				var out = [];
				var reporter = new VisualReporter(err -> out.push(err));
				reporter.report(e, source);
				new Error(InternalError, out.join('\n'));
			});
	}

	public function dispose() {}
}
