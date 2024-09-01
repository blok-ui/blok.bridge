package blok.bridge.util;

abstract TaskQueue(Array<Task<Nothing>>) {
	public function new() {
		this = [];
	}

	public function enqueue(task) {
		this.push(task);
	}

	public function parallel() {
		return Task.parallel(...this).next(_ -> Task.nothing());
	}

	public function sequence() {
		return Task.sequence(...this).next(_ -> Task.nothing());
	}
}
