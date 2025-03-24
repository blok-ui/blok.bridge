package spa.routes;

import blok.html.Html;
import blok.*;
import blok.router.Page;

class EditTask extends Page<'/task/{id:String}'> {
	function render():Child {
		return Html.view(<p>
			{HomePage.link().child('Home')}
			"The current task is: " id
		</p>);
	}
}
