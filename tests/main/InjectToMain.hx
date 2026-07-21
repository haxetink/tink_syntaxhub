package main;

class InjectToMain {
	public static function inject() {
		tink.SyntaxHub.transformMain.whenever(e -> macro {
			v = 42;
			$e;
		});
	}
}
