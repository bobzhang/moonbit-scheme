///|
test "scheme mid: fib program" {
  let program : String =
    #|(define fib
    #|    (lambda (n)
    #|      (if (< n 2)
    #|        n
    #|        (+ (fib (- n 2))
    #|           (fib (- n 1))))))
    #|
    #|(fib 27)
    #|

  let result = @ocamlscheme.eval_program(program)
  inspect(@ocamlscheme.expr_to_string(result), content="196418")
}
