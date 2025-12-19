///|
fn symbol_value_value(symbol : Symbol) -> LispExpr raise EvalError {
  match symbol.value {
    SymbolValue::Value(value) => value
    SymbolValue::Macro(_) => raise EvalError("symbol refers to macro")
  }
}

///|
fn env_get(env : Env, depth : Int, index : Int) -> LispExpr raise EvalError {
  match env.get(depth) {
    Some(frame) => {
      match frame.get(index) {
        Some(value) => value
        None => raise EvalError("env index out of bounds")
      }
    }
    None => raise EvalError("env depth out of bounds")
  }
}

///|
fn env_prepend(frame : Array[LispExpr], env : Env) -> Env {
  let next : Env = []
  next.push(frame)
  for item in env {
    next.push(item)
  }
  next
}

///|
fn apply_value(rt : Runtime, func : LispExpr, args : Array[LispExpr]) -> Array[LispExpr] raise EvalError {
  match func {
    LispExpr::Builtin(builtin) => [apply_builtin(rt, builtin, args)]
    LispExpr::Closure(code, closure_env) => eval_all(code, env_prepend(args, closure_env), rt)
    _ => raise EvalError("not a function")
  }
}

///|
fn eval_args_all(args : Array[LispCode], index : Int, env : Env, rt : Runtime) -> Array[Array[LispExpr]] raise EvalError {
  if index == args.length() {
    let empty : Array[LispExpr] = []
    [empty]
  } else {
    let head_results = eval_all(args[index], env, rt)
    let tail_results = eval_args_all(args, index + 1, env, rt)
    let combined : Array[Array[LispExpr]] = []
    for head in head_results {
      for tail in tail_results {
        let args_list : Array[LispExpr] = []
        args_list.push(head)
        for item in tail {
          args_list.push(item)
        }
        combined.push(args_list)
      }
    }
    combined
  }
}

///|
fn eval_all(code : LispCode, env : Env, rt : Runtime) -> Array[LispExpr] raise EvalError {
  match code {
    LispCode::Quote(value) => [value]
    LispCode::Global(symbol) => [symbol_value_value(symbol)]
    LispCode::Var(depth, index) => [env_get(env, depth, index)]
    LispCode::If(cond, cons, alt) => {
      let results : Array[LispExpr] = []
      for cond_value in eval_all(cond, env, rt) {
        let branch = if is_nil(cond_value) { alt } else { cons }
        let branch_results = eval_all(branch, env, rt)
        for value in branch_results {
          results.push(value)
        }
      }
      results
    }
    LispCode::Application(func, args) => {
      let results : Array[LispExpr] = []
      let func_values = eval_all(func, env, rt)
      let arg_values = eval_args_all(args, 0, env, rt)
      for func_value in func_values {
        for argv in arg_values {
          let applied = apply_value(rt, func_value, argv)
          for value in applied {
            results.push(value)
          }
        }
      }
      results
    }
    LispCode::BuildClosure(body) => [LispExpr::Closure(body, env)]
    LispCode::Amb(codes) => {
      let results : Array[LispExpr] = []
      for code in codes {
        let values = eval_all(code, env, rt)
        for value in values {
          results.push(value)
        }
      }
      results
    }
    LispCode::GlobalSet(symbol, code) => {
      let results : Array[LispExpr] = []
      for value in eval_all(code, env, rt) {
        symbol.value = SymbolValue::Value(value)
        results.push(LispExpr::Nil)
      }
      results
    }
    LispCode::GlobalSetMacro(symbol, code) => {
      let results : Array[LispExpr] = []
      for value in eval_all(code, env, rt) {
        symbol.value = SymbolValue::Macro(value)
        results.push(LispExpr::Nil)
      }
      results
    }
  }
}
