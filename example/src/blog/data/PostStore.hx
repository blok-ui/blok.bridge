package blog.data;

import blok.context.Context;
import blok.debug.Debug;
import kit.file.*;

using StringTools;
using haxe.io.Path;

enum MarkdownResult {
	Ok(frontMatter:Dynamic, body:String);
	Error(error:Error);
}

@:fallback(error('No PostStore found'))
class PostStore implements Context {
	final dir:Directory;

	public function new(dir) {
		this.dir = dir;
	}

	public function getPost(id:String):Task<Post> {
		return dir
			.file(id.withExtension('md'))
			.read()
			.next(contents -> switch parseFrontMatter(contents) {
				case Ok(frontMatter, body):
					Post.fromJson({
						slug: frontMatter.slug,
						title: frontMatter.title,
						body: body
					});
				case Error(error):
					error;
			});
	}

	function parseFrontMatter(contents:String):MarkdownResult {
		if (!contents.startsWith('---')) {
			return Ok({}, contents.trim());
		}

		var contents = contents.substr(3);
		var end = contents.indexOf('---');
		var frontMatter = contents.substr(3, end - 3);
		var body = contents.substr(end + 3);

		return Ok(Toml.parse(frontMatter), body.trim());
	}

	public function dispose() {}
}
