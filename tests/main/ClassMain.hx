package main;

import haxe.unit.TestRunner;

class ClassMain {
  static var v = 0;

  static function main() {
    // inject "v = 42;" via transformMain

    var t = new TestRunner();
    t.add(new Foo(v, 42));
    t.run();
  }
}