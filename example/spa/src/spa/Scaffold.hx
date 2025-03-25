package spa;

import blok.*;
import blok.bridge.Head;
import blok.html.Html;
import spa.AppRouter;

class Scaffold extends Component {
	function render():Child return Html.view(<html>
		<Head>
			<title>"Spa Example"</title>
		</Head>

		<body>
			<AppHeader />
			<main>
				<AppRouter />
			</main>
		</body>
	</html>);
}
