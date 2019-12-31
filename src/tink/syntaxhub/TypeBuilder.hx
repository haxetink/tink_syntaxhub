package tink.syntaxhub;

import tink.core.Option;

interface TypeBuilder{
  public function reader():Option<FrontendReader>;
  public function apply(context:FrontendContext):Void;
}