package;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

class Main extends TestCase {
	
	function testTxt()
		assertEquals('Hello, hello!!!', HelloWorld.TEXT);
	
	function testXml()
		assertEquals('<3', HelloWorld.XML.firstElement().firstChild().nodeValue);
		
	static function main() {
		var t = new TestRunner();
		t.add(new Main());
		t.run();
	}
	
}