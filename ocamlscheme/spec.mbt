///|
/// Spec for the Scheme interpreter (MoonBit port of ocamlscheme).

///|
pub(all) suberror ParseError String derive(Show, Eq)

///|
pub(all) suberror EvalError String derive(Show, Eq)

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
  Int(Int)
  Symbol(Symbol)
  Cons(LispExpr, LispExpr)
  Builtin(BuiltinFn)
  Closure(LispCode, Env)
}

///|
pub enum LispCode {
  Quote(LispExpr)
  Var(Int, Int)
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
