package blok.bridge.routing;

using StringTools;
using haxe.io.Path;

function normalizeUrl(url:String) {
  url = url.normalize().trim();
  if (!url.startsWith('/')) {
    url = '/' + url;
  }
  return url;
}
