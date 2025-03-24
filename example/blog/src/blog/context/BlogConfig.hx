package blog.context;

@:fallback(new BlogConfig({name: 'Not Found'}))
class BlogConfig extends SerializableObject implements Context {
	@:value public final name:String;

	public function dispose() {}
}
