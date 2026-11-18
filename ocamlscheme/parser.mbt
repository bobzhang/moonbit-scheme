///|
priv struct Reader {
  src : String
  mut index : Int32
}

///|
fn Reader::new(src : String) -> Reader {
  { src, index: 0, }
}

///|
fn Reader::peek(self : Reader) -> Char? {
  self.src.get_char(self.index)
}

///|
fn Reader::advance(self : Reader) -> Char? {
  match self.peek() {
    Some(ch) => {
      self.index = self.index + 1
      Some(ch)
    }
    None => None
  }
}

///|
fn is_whitespace(ch : Char) -> Bool {
  ch == ' ' || ch == '\n' || ch == '\t' || ch == '\r'
}

///|
fn is_delim(ch : Char) -> Bool {
  ch == '(' || ch == ')' || ch == '\'' || is_whitespace(ch) || ch == ';'
}

///|
fn Reader::skip_ws_and_comments(self : Reader) -> Unit {
  while true {
    match self.peek() {
      Some(ch) if is_whitespace(ch) => {
        ignore(self.advance())
        continue
      }
      Some(';') => {
        ignore(self.advance())
        while true {
          match self.peek() {
            Some('\n') => {
              ignore(self.advance())
              break
            }
            Some(_) => {
              ignore(self.advance())
              continue
            }
            None => break
          }
        }
        continue
      }
      _ => break
    }
  }
}

///|
fn Reader::expect(self : Reader, expected : Char) -> Unit raise ParseError {
  match self.advance() {
    Some(ch) if ch == expected => ()
    Some(_) => raise ParseError("unexpected character")
    None => raise ParseError("unexpected eof")
  }
}

///|
fn read_number(reader : Reader) -> Int32 {
  let mut value = 0
  while true {
    match reader.peek() {
      Some(ch) if ch.is_ascii_digit() => {
        value = value * 10 + (ch.to_int() - '0'.to_int())
        ignore(reader.advance())
        continue
      }
      _ => break
    }
  }
  value
}

///|
fn read_symbol(reader : Reader) -> String raise ParseError {
  let chars : Array[Char] = []
  while true {
    match reader.peek() {
      Some(ch) if !is_delim(ch) => {
        chars.push(ch)
        ignore(reader.advance())
        continue
      }
      _ => break
    }
  }
  if chars.length() == 0 {
    raise ParseError("empty symbol")
  }
  String::from_array(chars[:])
}

///|
fn read_expr(reader : Reader, rt : Runtime) -> LispExpr raise ParseError {
  reader.skip_ws_and_comments()
  match reader.peek() {
    None => raise ParseError("unexpected eof")
    Some('(') => {
      ignore(reader.advance())
      read_list(reader, rt)
    }
    Some(')') => raise ParseError("unexpected )")
    Some('.') => raise ParseError("unexpected .")
    Some('\'') => {
      ignore(reader.advance())
      let expr = read_expr(reader, rt)
      let quote_sym = rt.intern("quote")
      LispExpr::Cons(
        LispExpr::Symbol(quote_sym),
        LispExpr::Cons(expr, LispExpr::Nil),
      )
    }
    Some(ch) if ch.is_ascii_digit() => LispExpr::Int(read_number(reader))
    Some(_) => {
      let name = read_symbol(reader)
      LispExpr::Symbol(rt.intern(name))
    }
  }
}

///|
fn read_list(reader : Reader, rt : Runtime) -> LispExpr raise ParseError {
  reader.skip_ws_and_comments()
  match reader.peek() {
    None => raise ParseError("unexpected eof in list")
    Some(')') => {
      ignore(reader.advance())
      LispExpr::Nil
    }
    _ => {
      let head = read_expr(reader, rt)
      reader.skip_ws_and_comments()
      match reader.peek() {
        Some('.') => {
          ignore(reader.advance())
          let tail = read_expr(reader, rt)
          reader.skip_ws_and_comments()
          reader.expect(')')
          LispExpr::Cons(head, tail)
        }
        _ => {
          let tail = read_list(reader, rt)
          LispExpr::Cons(head, tail)
        }
      }
    }
  }
}

///|
fn read_expr_opt(reader : Reader, rt : Runtime) -> LispExpr? raise ParseError {
  reader.skip_ws_and_comments()
  match reader.peek() {
    None => None
    Some(_) => Some(read_expr(reader, rt))
  }
}

///|
fn parse_program(
  src : String,
  rt : Runtime,
) -> Array[LispExpr] raise ParseError {
  let reader = Reader::new(src)
  let exprs : Array[LispExpr] = []
  while true {
    match read_expr_opt(reader, rt) {
      Some(expr) => exprs.push(expr)
      None => break
    }
  }
  exprs
}
