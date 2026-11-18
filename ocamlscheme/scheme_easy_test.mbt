///|
test "scheme easy: arithmetic and list basics" {
  let add_result = @ocamlscheme.eval_program("(+ 1 2 3)")
  inspect(@ocamlscheme.expr_to_string(add_result), content="6")

  let cons_result = @ocamlscheme.eval_program("(cons 1 (cons 2 ()))")
  inspect(@ocamlscheme.expr_to_string(cons_result), content="(1 2)")

  let car_result = @ocamlscheme.eval_program("(car (cons 9 8))")
  inspect(@ocamlscheme.expr_to_string(car_result), content="9")

  let null_result = @ocamlscheme.eval_program("(null? ())")
  inspect(@ocamlscheme.expr_to_string(null_result), content="t")
}

///|
test "scheme easy: quote and symbol" {
  let quoted_list = @ocamlscheme.eval_program("'(1 2 3)")
  inspect(@ocamlscheme.expr_to_string(quoted_list), content="(1 2 3)")

  let quoted_symbol = @ocamlscheme.eval_program("'abc")
  inspect(@ocamlscheme.expr_to_string(quoted_symbol), content="abc")
}
