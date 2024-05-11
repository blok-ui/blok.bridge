package blok.bridge;

interface DocumentController {
	public function setTitle(title:String):Void;
	public function setMetadata(key:String, value:String):Void;
	public function linkCss(path:String, ?id:String):Void;
	public function linkScript(path:String, ?id:String):Void;
}
