package;

import tink.syntaxhub.*;
import haxe.macro.Expr;
import haxe.macro.Context;

import haxe.ds.Option;

class XmlFrontend implements TypeBuilder {

  var file : String;
  var text : String;

  public function new() {}
  
  public function extensions() 
    return ['xml'].iterator();
    
  public function apply(context:FrontendContext):Void {
    
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
  public function reader(){
    return Some({
      extensions  : function() return ['xml'].iterator(),
      parse       : function(file:String):Void{
        this.file = file;
        this.text = sys.io.File.getContent(file);
      }
    });
  }
  static function use()
    tink.SyntaxHub.frontends.whenever(new XmlFrontend());
}