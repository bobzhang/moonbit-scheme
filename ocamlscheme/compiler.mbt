///|
type CompileEnv = Array[Array[String]]

///|
fn env_lookup(name : String, env : CompileEnv) -> (Int32, Int32)? {
  let mut depth = 0
  for frame in env {
    let mut index = 0
    for item in frame {
      if item == name {
        return Some((depth, index))
      }
      index = index + 1
    }
    depth = depth + 1
  }
  None
}

///|
fn compile_env_prepend(names : Array[String], env : CompileEnv) -> CompileEnv {
  let next : CompileEnv = []
  next.push(names)
  for frame in env {
    next.push(frame)
  }
  next
}

///|
fn list_to_array(list : LispExpr) -> Array[LispExpr] raise EvalError {
  let out : Array[LispExpr] = []
  let mut cur = list
  while true {
    match cur {
      LispExpr::Nil => break
      LispExpr::Cons(car, cdr) => {
        out.push(car)
        cur = cdr
      }
      _ => raise EvalError("expected list")
    }
  }
  out
}

///|
fn list_to_symbol_names(list : LispExpr) -> Array[String] raise EvalError {
  let out : Array[String] = []
  let mut cur = list
  while true {
    match cur {
      LispExpr::Nil => break
      LispExpr::Cons(car, cdr) => {
        match car {
          LispExpr::Symbol(sym) => out.push(sym.name)
          _ => raise EvalError("expected symbol")
        }
        cur = cdr
      }
      _ => raise EvalError("expected list")
    }
  }
  out
}

///|
fn compile_application(
  func : LispExpr,
  args : LispExpr,
  env : CompileEnv,
) -> LispCode raise EvalError {
  let arg_items = list_to_array(args)
  let compiled_args : Array[LispCode] = []
  for item in arg_items {
    compiled_args.push(compile(item, env))
  }
  LispCode::Application(compile(func, env), compiled_args)
}

///|
fn compile(expr : LispExpr, env : CompileEnv) -> LispCode raise EvalError {
  match expr {
    LispExpr::Nil => LispCode::Quote(expr)
    LispExpr::Int(_) => LispCode::Quote(expr)
    LispExpr::Builtin(_) => LispCode::Quote(expr)
    LispExpr::Closure(_, _) => LispCode::Quote(expr)
    LispExpr::Symbol(sym) =>
      match env_lookup(sym.name, env) {
        Some((depth, index)) => LispCode::Var(depth, index)
        None => LispCode::Global(sym)
      }
    LispExpr::Cons(car, cdr) =>
      match car {
        LispExpr::Symbol(sym) =>
          if sym.name == "quote" {
            match cdr {
              LispExpr::Cons(value, LispExpr::Nil) => LispCode::Quote(value)
              _ => raise EvalError("invalid quote")
            }
          } else if sym.name == "if" {
            match cdr {
              LispExpr::Cons(
                cond,
                LispExpr::Cons(cons, LispExpr::Cons(alt, LispExpr::Nil)),
              ) =>
                LispCode::If(
                  compile(cond, env),
                  compile(cons, env),
                  compile(alt, env),
                )
              _ => raise EvalError("invalid if")
            }
          } else if sym.name == "lambda" {
            match cdr {
              LispExpr::Cons(args, LispExpr::Cons(body, LispExpr::Nil)) => {
                let names = list_to_symbol_names(args)
                let next_env = compile_env_prepend(names, env)
                LispCode::BuildClosure(compile(body, next_env))
              }
              _ => raise EvalError("invalid lambda")
            }
          } else if sym.name == "amb" {
            let items = list_to_array(cdr)
            let compiled : Array[LispCode] = []
            for item in items {
              compiled.push(compile(item, env))
            }
            LispCode::Amb(compiled)
          } else if sym.name == "define" {
            match cdr {
              LispExpr::Cons(
                LispExpr::Symbol(name_sym),
                LispExpr::Cons(value, LispExpr::Nil),
              ) => LispCode::GlobalSet(name_sym, compile(value, env))
              _ => raise EvalError("invalid define")
            }
          } else if sym.name == "define-macro" {
            match cdr {
              LispExpr::Cons(
                LispExpr::Symbol(name_sym),
                LispExpr::Cons(value, LispExpr::Nil),
              ) => LispCode::GlobalSetMacro(name_sym, compile(value, env))
              _ => raise EvalError("invalid define-macro")
            }
          } else {
            compile_application(car, cdr, env)
          }
        _ => compile_application(car, cdr, env)
      }
  }
}
