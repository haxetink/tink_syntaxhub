import tink.syntaxhub.*;

import haxe.macro.Expr;
import haxe.macro.Context;

class TxtFrontend implements FrontendPlugin {
  
  public function new() {}
  
  public function extensions() 
    return ['txt'].iterator();
  
  public function parse(file:String, context:FrontendContext):Void {
    
    var text = sys.io.File.getContent(file);
    var pos = Context.makePosition({ file: file, min: 0, max: text.length });
    
    context.getType().fields.push({
      name: 'TEXT',
      access: [AStatic, APublic],
      kind: FProp('default', 'null', macro : String, macro $v{text}),
      pos: pos,
    });
  }
  static function use()
    tink.SyntaxHub.frontends.whenever(new TxtFrontend());
}