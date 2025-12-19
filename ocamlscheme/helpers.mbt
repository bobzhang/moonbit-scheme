///|
fn is_nil(expr : LispExpr) -> Bool {
  match expr {
    LispExpr::Nil => true
    _ => false
  }
}
