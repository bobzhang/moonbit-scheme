///|
fn macroexpand_list(rt : Runtime, list_expr : LispExpr) -> Array[LispExpr] raise EvalError {
  let items = list_to_array(list_expr)
  let expanded : Array[LispExpr] = []
  for item in items {
    expanded.push(macroexpand(rt, item))
  }
  expanded
}

///|
fn macroexpand(rt : Runtime, expr : LispExpr) -> LispExpr raise EvalError {
  match expr {
    LispExpr::Cons(LispExpr::Symbol(sym), args) => {
      match sym.value {
        SymbolValue::Macro(macro_value) => {
          let expanded_args = macroexpand_list(rt, args)
          let results = apply_value(rt, macro_value, expanded_args)
          if results.length() != 1 {
            raise EvalError("macro must return exactly one value")
          }
          results[0]
        }
        _ => LispExpr::Cons(LispExpr::Symbol(sym), macroexpand(rt, args))
      }
    }
    LispExpr::Cons(car, cdr) => LispExpr::Cons(macroexpand(rt, car), macroexpand(rt, cdr))
    _ => expr
  }
}
