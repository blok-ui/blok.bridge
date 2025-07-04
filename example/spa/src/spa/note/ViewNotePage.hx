package spa.note;

import blok.*;
import blok.html.Html;
import blok.router.Page;
import spa.ui.*;

class ViewNotePage extends Page<'/node/{id:String}'> {
	@:context final notebook:Notebook;

	public function render():Child {
		return Html.view(<PageLayout name="Edit Note">
			<p>"Test"</p>
		</PageLayout>);
	}
}
