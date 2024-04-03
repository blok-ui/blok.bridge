package blok.bridge;

import blok.bridge.project.Project;

class Bridge {
  public static function start(render, ?fs) {
    var embed = Project.embed();
    return macro new blok.bridge.Bridge($embed, $render, ${fs ?? macro null});
  }
}
