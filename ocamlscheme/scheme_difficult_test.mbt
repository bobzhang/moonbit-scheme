///|
test "scheme difficult: amb subset sum" {
  let program : String =
    #|(define fail
    #|    (lambda ()
    #|      (amb)))
    #|
    #|(define assert
    #|    (lambda (x)
    #|      (if x
    #|        ()
    #|        (fail))))
    #|
    #|(define member?
    #|    (lambda (i lst)
    #|      (if (null? lst)
    #|        ()
    #|        (if (= (car lst) i)
    #|          t
    #|          (member? i (cdr lst))))))
    #|
    #|(define all-different
    #|    (lambda (l)
    #|      (if (null? l)
    #|        t
    #|        (if (member? (car l) (cdr l))
    #|          ()
    #|          (all-different (cdr l))))))
    #|
    #|(define non-zero-digit
    #|    (lambda ()
    #|      (amb 1 2 3 4 5 6 7 8 9)))
    #|
    #|(define digit
    #|    (lambda ()
    #|      (amb 0 (non-zero-digit))))
    #|
    #|(define sum
    #|    (lambda (l)
    #|      (if (null? l)
    #|        0
    #|        (+ (car l) (sum (cdr l))))))
    #|
    #|(define for-all-subsets
    #|    (lambda (set func)
    #|      (if (null? set)
    #|        (func ())
    #|        (for-all-subsets (cdr set)
    #|          (lambda (subset)
    #|            (func (amb subset (cons (car set) subset))))))))
    #|
    #|(for-all-subsets '(5 17 27 41 58 63 86 99 114 125)
    #|  (lambda (l)
    #|    (begin
    #|      (assert (= (sum l) 313))
    #|      l)))
    #|

  let results = @ocamlscheme.eval_program_all(program)
  inspect(results.length(), content="1")
  inspect(@ocamlscheme.expr_to_string(results[0]), content="(17 27 58 86 125)")
}
