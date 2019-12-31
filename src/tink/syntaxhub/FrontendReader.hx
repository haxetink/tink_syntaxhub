package tink.syntaxhub;

typedef FrontendReader = {
  function extensions():Iterator<String>;
  function parse(path:String):Void;
}