///|
fn expect_int(value : LispExpr) -> Int raise EvalError {
  match value {
    LispExpr::Int(i) => i
    _ => raise EvalError("expected int")
  }
}

///|
fn apply_builtin(rt : Runtime, builtin : BuiltinFn, args : Array[LispExpr]) -> LispExpr raise EvalError {
  match builtin {
    BuiltinFn::Plus => {
      let mut sum = 0
      for arg in args {
        sum = sum + expect_int(arg)
      }
      LispExpr::Int(sum)
    }
    BuiltinFn::Minus => {
      if args.length() == 0 {
        raise EvalError("- expects at least one argument")
      }
      let first = expect_int(args[0])
      let mut sum = 0
      for arg in args {
        sum = sum + expect_int(arg)
      }
      LispExpr::Int(first + first - sum)
    }
    BuiltinFn::Mult => {
      let mut product = 1
      for arg in args {
        product = product * expect_int(arg)
      }
      LispExpr::Int(product)
    }
    BuiltinFn::NumbersEqual => {
      if args.length() != 2 {
        raise EvalError("= expects two arguments")
      }
      let left = expect_int(args[0])
      let right = expect_int(args[1])
      if left == right {
        rt.true_expr()
      } else {
        LispExpr::Nil
      }
    }
    BuiltinFn::Less => {
      if args.length() != 2 {
        raise EvalError("< expects two arguments")
      }
      let left = expect_int(args[0])
      let right = expect_int(args[1])
      if left < right {
        rt.true_expr()
      } else {
        LispExpr::Nil
      }
    }
    BuiltinFn::Cons => {
      if args.length() != 2 {
        raise EvalError("cons expects two arguments")
      }
      LispExpr::Cons(args[0], args[1])
    }
    BuiltinFn::Car => {
      if args.length() != 1 {
        raise EvalError("car expects one argument")
      }
      match args[0] {
        LispExpr::Cons(car, _) => car
        _ => raise EvalError("car expects a cons")
      }
    }
    BuiltinFn::Cdr => {
      if args.length() != 1 {
        raise EvalError("cdr expects one argument")
      }
      match args[0] {
        LispExpr::Cons(_, cdr) => cdr
        _ => raise EvalError("cdr expects a cons")
      }
    }
    BuiltinFn::NullP => {
      if args.length() != 1 {
        raise EvalError("null? expects one argument")
      }
      let arg = args[0]
      if is_nil(arg) { rt.true_expr() } else { LispExpr::Nil }
    }
    BuiltinFn::Begin => {
      if args.length() == 0 {
        LispExpr::Nil
      } else {
        args[args.length() - 1]
      }
    }
  }
}
