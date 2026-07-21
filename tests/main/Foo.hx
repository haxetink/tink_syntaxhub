package main;

import haxe.unit.TestCase;

class Foo extends TestCase {
  final v:Int;
  final expected:Int;

  public function new(v:Int, expected:Int) {
    super();
    this.v = v;
    this.expected = expected;
  }

  public function testValue() {
    assertEquals(expected, v);
  }
}