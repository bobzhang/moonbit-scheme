///|
test "scheme easy: arithmetic and list basics" {
  let add_result = eval_program("(+ 1 2 3)")
  inspect(expr_to_string(add_result), content="6")

  let cons_result = eval_program("(cons 1 (cons 2 ()))")
  inspect(expr_to_string(cons_result), content="(1 2)")

  let car_result = eval_program("(car (cons 9 8))")
  inspect(expr_to_string(car_result), content="9")

  let null_result = eval_program("(null? ())")
  inspect(expr_to_string(null_result), content="t")
}

///|
test "scheme easy: quote and symbol" {
  let quoted_list = eval_program("'(1 2 3)")
  inspect(expr_to_string(quoted_list), content="(1 2 3)")

  let quoted_symbol = eval_program("'abc")
  inspect(expr_to_string(quoted_symbol), content="abc")
}
