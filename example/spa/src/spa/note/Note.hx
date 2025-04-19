package spa.note;

import blok.data.SerializableModel;

@:forward
abstract NoteId(String) to String {
	public function new(value) {
		this = value;
	}

	public function compare(other:NoteId) {
		return this == (other : String);
	}
}

class Note extends SerializableModel {
	@:value public final id:NoteId;
	@:signal public final title:String;
	@:signal public final content:String;
}
