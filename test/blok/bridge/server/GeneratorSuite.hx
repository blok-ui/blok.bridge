package blok.bridge.server;

import kit.http.Request;
import fixture.Routes;
import blok.bridge.log.*;

class GeneratorSuite extends Suite {
	@:test(expects = 1)
	function simpleHtml() {
		var generator = new Generator(() -> Routes.node({}), new NullLogger(), []);
		return generator.generatePage(new RequestContext(
			new Config({version: '0.0.1', clientDependencies: InheritDependencies}),
			new Request(Get, '/')
		)).inspect(document -> {
			document.toString({includeTextMarkers: false}).equals('Home Page');
		});
	}

	@:test(expects = 1)
	function handlesErrorsCorrectly() {
		var generator = new Generator(() -> Routes.node({}), new NullLogger(), []);
		return generator.generatePage(new RequestContext(
			new Config({version: '0.0.1', clientDependencies: InheritDependencies}),
			new Request(Get, '/error')
		)).inspect(document -> {
			document.toString({includeTextMarkers: false}).equals('Expected failure');
		});
	}

	@:test(expects = 1)
	function handlesSuspenseCorrectly() {
		var generator = new Generator(() -> Routes.node({}), new NullLogger(), []);
		return generator.generatePage(new RequestContext(
			new Config({version: '0.0.1', clientDependencies: InheritDependencies}),
			new Request(Get, '/suspends')
		)).inspect(document -> {
			document.toString({includeTextMarkers: false}).equals('Suspended');
		});
	}

	// @todo: Test various render scenarios, including suspense and errors
}
