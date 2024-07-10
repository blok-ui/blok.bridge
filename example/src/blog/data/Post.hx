package blog.data;

class Post extends Model {
	@:constant public final slug:String;
	@:constant public final title:String;
	@:constant public final body:PostContent;
}
