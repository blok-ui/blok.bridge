function main() {
  #if blok.server
  var comp = blok.html.Server.mount(
    new blok.html.server.Element('div', { id: 'root' }),
    () -> blok.html.View.view(<div>
      <h1>"Islands Example"</h1>
      // @todo: figure out how to handle this problem, where
      // we have to use the `island` method:
      <div>{ex.Counter.island({ count: 1 })}</div>
      // @todo: the following seems to cause issues with the 
      // macro -- probably a problem with type ordering. Consider
      // making building the blok.html.Html class an init macro?
      // <div><ex.Counter.island count="1" /></div>
    </div>)
  );
  var root:blok.html.server.Element = comp.getRealNode();
  var out = '<!doctype html>
<html>
  <head>
    <script src="../dist/index.js" defer></script>
  </head>
  <body>
    ${root.toString()}
  </body>
</html>
';
  trace(out);
  #else
  var islands = new blok.bridge.Islands<['ex']>();
  islands.hydrate();
  #end
}
