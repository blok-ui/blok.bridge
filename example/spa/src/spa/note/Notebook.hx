package spa.note;

import blok.*;
import blok.data.SerializableModel;

@:fallback(new Notebook({notes: []}))
class Notebook extends SerializableModel implements Context {
	@:signal public final notes:Array<Note>;

	public function add(note:Note) {
		notes.update(notes -> notes.concat([note]));
	}

	public function remove(note:Note) {
		notes.update(notes -> notes.filter(target -> !note.id.compare(target.id)));
	}
}
