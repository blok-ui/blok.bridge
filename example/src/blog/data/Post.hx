package blog.data;

class Post extends Structure {
	@:constant public final slug:String;
	@:constant public final title:String;
	@:constant public final body:Child;
}
