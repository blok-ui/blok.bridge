package blok.bridge;

interface Plugin {
	public function apply():Task<Nothing>;
}
