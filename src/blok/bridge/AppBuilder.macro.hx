package blok.bridge;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import kit.macro.*;

using haxe.macro.Tools;
using kit.Hash;
using kit.macro.Tools;

function buildGeneric() {
	return switch Context.getLocalType() {
		case TInst(_, params):
			buildApp(params);
		default:
			throw 'assert';
	}
}

private function buildApp(types:Array<Type>) {
	var pack = ['blok', 'bridge'];
	var name = 'App_' + types.map(type -> type.stringifyTypeForClassName()).join('_').hash();
	var path:TypePath = {pack: pack, name: name};

	if (path.typePathExists()) return TPath(path);

	var fields = new ClassFieldCollection([]);
	var body:Array<Expr> = [];
	var pos = Context.currentPos();

	for (type in types) {
		if (!Context.unify(type, Context.getType('capsule.Module'))) {
			Context.error('All params must be capsule.Modules', Context.currentPos());
		}
		var path = type.toComplexType().toString().split('.');
		body.push(macro container.use($p{path}));
	}

	var pos = Context.currentPos();

	fields.add(macro class {
		final config:blok.bridge.Config;
		final render:blok.bridge.Render;

		public function new(config, render) {
			this.config = new blok.bridge.Config(config);
			this.render = render;
		}

		public function provide(container:capsule.Container) {
			container.use(blok.bridge.module.CoreModule);
			container.map(blok.bridge.Config).to(config);
			container.map(blok.bridge.Render).to(render);
			$b{body};
		}

		public function createContainer():capsule.Container {
			return @:pos(pos) capsule.Container.build(this);
		}

		public function run() {
			return createContainer()
				.get(blok.bridge.server.Runner)
				.run()
				.eager();
		}
	});

	Context.defineType({
		name: name,
		pack: pack,
		pos: (macro null).pos,
		kind: TDClass(null, [
			{
				pack: ['capsule'],
				name: 'Module'
			}
		], false, true, false),
		fields: fields.export()
	});

	return TPath(path);
}
