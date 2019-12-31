import tink.syntaxhub.*;

import haxe.ds.Option;
import haxe.macro.Expr;
import haxe.macro.Context;

class TxtFrontend implements TypeBuilder {
  
  var file : String;
  var text : String;

  public function new() {}
  
  public function apply(context:FrontendContext):Void {
    var pos = Context.makePosition({ file: file, min: 0, max: text.length });
    
    context.getType().fields.push({
      name: 'TEXT',
      access: [AStatic, APublic],
      kind: FProp('default', 'null', macro : String, macro $v{text}),
      pos: pos,
    });
  }
  public function reader(){
    return Some({
      extensions  : function():Iterator<String> return ['txt'].iterator(),
      parse       : function(file:String):Void{
        this.file = file;
        this.text = sys.io.File.getContent(file);
      }
    });
  }
  static function use()
    tink.SyntaxHub.frontends.whenever(new TxtFrontend());
}