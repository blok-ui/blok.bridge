package spa.data;

import blok.data.Model;

@:forward
abstract NoteId(String) to String {
	public function new(value) {
		this = value;
	}

	public function compare(other:NoteId) {
		return this == (other : String);
	}
}

class Note extends Model {
	@:value public final id:NoteId;
	@:signal public final title:String;
	@:signal public final content:String;
}
