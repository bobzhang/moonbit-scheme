///|
fn list_to_string(expr : LispExpr) -> String {
  match expr {
    LispExpr::Cons(car, LispExpr::Cons(cadr, cddr)) =>
      expr_to_string(car) + " " + list_to_string(LispExpr::Cons(cadr, cddr))
    LispExpr::Cons(car, LispExpr::Nil) => expr_to_string(car)
    LispExpr::Cons(car, cdr) =>
      expr_to_string(car) + " . " + expr_to_string(cdr)
    _ => ""
  }
}

///|
pub fn expr_to_string(expr : LispExpr) -> String {
  match expr {
    LispExpr::Nil => "()"
    LispExpr::Int(i) => i.to_string()
    LispExpr::Symbol(sym) => sym.name
    LispExpr::Cons(car, cdr) =>
      "(" + list_to_string(LispExpr::Cons(car, cdr)) + ")"
    LispExpr::Builtin(_) => "#<builtin>"
    LispExpr::Closure(_, _) => "#<closure>"
  }
}
