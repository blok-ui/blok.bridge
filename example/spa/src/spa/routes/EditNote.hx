package spa.routes;

import blok.*;
import blok.html.Html;
import blok.router.Page;
import spa.ui.*;

class EditNote extends Page<'/note/{id:String}'> {
	function render():Child {
		return Html.view(<PageLayout name="Edit Note">
			<p>"Test"</p>
		</PageLayout>);
	}
}
