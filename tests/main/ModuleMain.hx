package main;

import haxe.unit.TestRunner;

var v = 0;

// this is the entry point
function main() {
  // inject "v = 42;" via transformMain

  var t = new TestRunner();
  t.add(new Foo(v, 42));
  t.run();
  
  ModuleMain.main();
}

class ModuleMain {
  static var v = 0;
  static var executed = false;

  // this is NOT the entry point
  public static function main() {
    var t = new TestRunner();
    t.add(new Foo(v, 0));
    t.run();
  }
}