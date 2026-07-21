package tink;

import haxe.macro.*;
import haxe.macro.Expr;
import haxe.ds.Option;
import tink.macro.ClassBuilder;
import tink.priority.Queue;
import tink.syntaxhub.*;

using tink.CoreApi;
using haxe.macro.Tools;

class SyntaxHub {
  static var MODULE_MAIN:Null<String> = null;
  static var MAIN:Null<String> = null;
  static var registered = false;
  static var mainTransformed = false;

  static function use() {
    if (registered) return;
    registered = true;

    var args = Sys.args();

    // TODO: maybe we want to update this in tink_macro
    switch tink.MacroApi.getMainClass() {
      case Some(main):
        MAIN = main;
        final pack = main.split('.');
        final name = pack.pop();
        MODULE_MAIN = pack.concat(['_${name}', '${name}_Fields_']).join('.');
      case None:
    }

    FrontendContext.resetCache();
    classLevel.whenever(makeSyntax(exprLevel.appliedTo), exprLevel.id);//Apperently reinserting this every time is more reliable with the cache
    Context.onTypeNotFound(FrontendContext.findType);
    Compiler.addGlobalMetadata('', '@:build(tink.SyntaxHub.build())', true, true, false);

  }

  static function build():Array<Field>
    return
      switch Context.getLocalType() {
        case null: null;
        case TInst(_.get() => c, _):

          var builder = new ClassBuilder();

          var changed = false;

          for (plugin in classLevel.getData())
            changed = plugin(builder) || changed;

          changed = applyMainTransform(builder) || changed;

          if (changed)
            builder.export(builder.target.meta.has(':explain'));
          else
            null;
        default: null;
      }

  static public var classLevel(default, null) = new Queue<ClassBuilder->Bool>();
  static public var exprLevel(default, null) = new ExprLevelSyntax('tink.SyntaxHub::exprLevel');
  static public var transformMain(default, null) = new Queue<Expr->Expr>();

  static public var frontends(get, never):Queue<FrontendPlugin>;

    static inline function get_frontends()
      return FrontendContext.plugins;

  static public function makeSyntax(rule:ClassBuilder->Option<Expr->Expr>):ClassBuilder->Bool
    return function (ctx:ClassBuilder)
      return switch rule(ctx) {
        case Some(rule):

          function transform(f:Function)
            if (f.expr != null)
              f.expr = rule(f.expr);

          if (ctx.hasConstructor())
            ctx.getConstructor().onGenerate(transform);

          for (m in ctx)
            switch m.kind {
              case FFun(f): transform(f);
              case FProp(_, _, _, e), FVar(_, e):
                if (e != null)
                  e.expr = rule(e).expr;//TODO: it might be better to just create a new kind, rather than modifying the expression in place
            }

          true;
        case None:
          false;
      }

  static function applyMainTransform(c:ClassBuilder) {
    if (mainTransformed) return false;

    final name = c.target.pack.concat([c.target.name]).join('.');

    function getMainFunction() {
      return if (name == MAIN || name == MODULE_MAIN) {
        c.memberByName('main').flatMap(f -> f.getFunction().map(fn -> {field: f, fn: fn}));
      } else {
        Failure(new Error('Main function not found'));
      }
    }

    switch getMainFunction() {
      case Success({field: main, fn: f}):
        if (f.expr == null)
          f.expr = macro @:pos(main.pos) {};
        for(rule in transformMain)
          f.expr = rule(f.expr);
        return mainTransformed = true;
      case Failure(_):
        return false;
    }
  }
}