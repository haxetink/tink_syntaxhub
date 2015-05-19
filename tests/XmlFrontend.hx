package;

import tink.syntaxhub.*;
import haxe.macro.Expr;
import haxe.macro.Context;

class XmlFrontend implements FrontendPlugin {
	
	public function new() {}
	
	public function extensions() 
		return ['xml'].iterator();
		
	public function parse(file:String, context:FrontendContext):Void {
		
		var text = sys.io.File.getContent(file);
		var pos = Context.makePosition({ file: file, min: 0, max: text.length });
		
		try
			Xml.parse(text)
		catch (e:Dynamic)
			Context.error('Failed to parse $file because: $e', pos);
		
		context.getType().fields.push({
			name: 'XML',
			access: [AStatic, APublic],
			kind: FProp('default', 'null', macro : Xml, macro Xml.parse($v{text})),
			pos: pos,
		});
	}
	static function use()
		tink.SyntaxHub.frontends.whenever(new XmlFrontend());
}