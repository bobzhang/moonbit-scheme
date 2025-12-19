///|
pub fn eval_program(src : String) -> LispExpr raise {
  let results = eval_program_all(src)
  match results.get(0) {
    Some(value) => value
    None => raise EvalError("no result")
  }
}

///|
pub fn eval_program_all(src : String) -> Array[LispExpr] raise {
  let rt = Runtime::new()
  let exprs = parse_program(src, rt)
  let compile_env : CompileEnv = []
  let runtime_env : Env = []

  let mut last_results : Array[LispExpr] = []
  let mut index = 0
  while index < exprs.length() {
    let expr = exprs[index]
    let expanded = macroexpand(rt, expr)
    let code = compile(expanded, compile_env)
    if index == exprs.length() - 1 {
      last_results = eval_all(code, runtime_env, rt)
    } else {
      let _ = eval_all(code, runtime_env, rt)
    }
    index = index + 1
  }
  last_results
}
