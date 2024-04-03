import ex.page.*;
import blok.router.*;
import blok.bridge.Bridge;

function main() {
  Bridge
    .start(() -> Router.node({
      routes: [
        new Route<'/'>(_ -> HomePage.node({})),
        new Route<'/counter/{count:Int}'>(params -> CounterPage.node({ initialCount: params.count }))
      ],
      fallback: _ -> 'Not found'
    }))
    .generate()
    .next(app -> app.process())
    .handle(result -> switch result {
      case Ok(_): trace('Created');
      case Error(error): trace(error.message);
    });
}
