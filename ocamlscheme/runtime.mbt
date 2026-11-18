///|
priv struct Runtime {
  symbols : Map[String, Symbol]
  t_symbol : Symbol
}

///|
fn Runtime::new() -> Runtime {
  let symbols : Map[String, Symbol] = Map([])
  let t_symbol = Symbol::{
    name: "t",
    value: SymbolValue::Value(LispExpr::Nil),
  }
  let nil_symbol = Symbol::{
    name: "nil",
    value: SymbolValue::Value(LispExpr::Nil),
  }

  symbols["t"] = t_symbol
  symbols["nil"] = nil_symbol

  t_symbol.value = SymbolValue::Value(LispExpr::Symbol(t_symbol))
  nil_symbol.value = SymbolValue::Value(LispExpr::Nil)

  let runtime = Runtime::{ symbols, t_symbol, }
  runtime.install_builtins()
  runtime
}

///|
fn Runtime::intern(self : Runtime, name : String) -> Symbol {
  match self.symbols.get(name) {
    Some(symbol) => symbol
    None => {
      let symbol = Symbol::{ name, value: SymbolValue::Value(LispExpr::Nil), }
      self.symbols[name] = symbol
      symbol
    }
  }
}

///|
fn Runtime::set_symbol(
  self : Runtime,
  name : String,
  value : SymbolValue,
) -> Symbol {
  let symbol = self.intern(name)
  symbol.value = value
  symbol
}

///|
fn Runtime::true_expr(self : Runtime) -> LispExpr {
  LispExpr::Symbol(self.t_symbol)
}

///|
fn Runtime::install_builtins(self : Runtime) -> Unit {
  ignore(
    self.set_symbol("+", SymbolValue::Value(LispExpr::Builtin(BuiltinFn::Plus))),
  )
  ignore(
    self.set_symbol(
      "-",
      SymbolValue::Value(LispExpr::Builtin(BuiltinFn::Minus)),
    ),
  )
  ignore(
    self.set_symbol("*", SymbolValue::Value(LispExpr::Builtin(BuiltinFn::Mult))),
  )
  ignore(
    self.set_symbol(
      "=",
      SymbolValue::Value(LispExpr::Builtin(BuiltinFn::NumbersEqual)),
    ),
  )
  ignore(
    self.set_symbol("<", SymbolValue::Value(LispExpr::Builtin(BuiltinFn::Less))),
  )
  ignore(
    self.set_symbol(
      "cons",
      SymbolValue::Value(LispExpr::Builtin(BuiltinFn::Cons)),
    ),
  )
  ignore(
    self.set_symbol(
      "car",
      SymbolValue::Value(LispExpr::Builtin(BuiltinFn::Car)),
    ),
  )
  ignore(
    self.set_symbol(
      "cdr",
      SymbolValue::Value(LispExpr::Builtin(BuiltinFn::Cdr)),
    ),
  )
  ignore(
    self.set_symbol(
      "null?",
      SymbolValue::Value(LispExpr::Builtin(BuiltinFn::NullP)),
    ),
  )
  ignore(
    self.set_symbol(
      "begin",
      SymbolValue::Value(LispExpr::Builtin(BuiltinFn::Begin)),
    ),
  )
}
