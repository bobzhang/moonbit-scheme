///|
/// Spec for the Scheme interpreter (MoonBit port of ocamlscheme).

///|
#derive(Debug, Eq)
pub(all) suberror ParseError {
  ParseError(String)
}

///|
#derive(Debug, Eq)
pub(all) suberror EvalError {
  EvalError(String)
}

///|
pub enum BuiltinFn {
  Plus
  Minus
  Mult
  NumbersEqual
  Less
  Cons
  Car
  Cdr
  NullP
  Begin
}

///|
pub enum LispExpr {
  Nil
  Int(Int32)
  Symbol(Symbol)
  Cons(LispExpr, LispExpr)
  Builtin(BuiltinFn)
  Closure(LispCode, Env)
}

///|
pub enum LispCode {
  Quote(LispExpr)
  Var(Int32, Int32)
  Global(Symbol)
  If(LispCode, LispCode, LispCode)
  Application(LispCode, Array[LispCode])
  BuildClosure(LispCode)
  Amb(Array[LispCode])
  GlobalSet(Symbol, LispCode)
  GlobalSetMacro(Symbol, LispCode)
}

///|
pub enum SymbolValue {
  Value(LispExpr)
  Macro(LispExpr)
}

///|
pub(all) struct Symbol {
  name : String
  mut value : SymbolValue
}

///|
type Env = Array[Array[LispExpr]]

///|
#declaration_only
pub fn eval_program(src : String) -> LispExpr raise {
  ...
}

///|
#declaration_only
pub fn eval_program_all(src : String) -> Array[LispExpr] raise {
  ...
}

///|
#declaration_only
pub fn expr_to_string(expr : LispExpr) -> String {
  ...
}

///|
pub impl Show for ParseError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub impl Show for EvalError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}
