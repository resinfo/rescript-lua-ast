let reduce = Belt.List.reduce

open Ast
open Writer

let rec writeBlock = (w, t) => {
  switch t {
  | Block(list{}) => w
  | Block(list{head, ...rest}) =>
    w
    ->writeStatement(head)
    ->reduce(rest, _, (w, t) => {
      w->newline->writeStatement(t)
    })
  }
}

and writeStatement = (w, t) => {
  switch t {
  | Do(list{}) => w->write("do end")
  | Do(list{head, ...statements}) =>
    w
    ->write("do")
    ->indentThenNewline
    ->writeStatement(head)
    ->reduce(statements, _, (w, t) => {
      w->writeStatement(t)->newline
    })
    ->outdentThenNewline
    ->write("end")
  | Set((lhs, list{}), (Function(idents, dots, block), list{})) =>
    let w = w->write("function ")->writeLhs(lhs)->write("(")

    let w = switch (idents, dots) {
    | (list{}, None) => w
    | (list{}, Some(dots)) => w->writeDots(dots)
    | (list{head, ...rest}, dots) => {
        let w = w->writeIdent(head)->reduce(rest, _, writeIdent)

        switch dots {
        | None => w
        | Some(dots) => w->write(", ")->writeDots(dots)
        }
      }
    }

    w->write(")")->indentThenNewline->writeBlock(block)->outdentThenNewline->write("end")

  | Set((lhs, lhss), (expr, exprs)) =>
    w
    ->writeLhs(lhs)
    ->reduce(lhss, _, (w, t) => {
      w->write(", ")->writeLhs(t)
    })
    ->write(" = ")
    ->writeExpr(expr)
    ->reduce(exprs, _, (w, t) => {
      w->write(", ")->writeExpr(t)
    })

  | While(expr, block) =>
    w
    ->write("while ")
    ->writeExpr(expr)
    ->write(" do")
    ->indentThenNewline
    ->writeBlock(block)
    ->outdentThenNewline
    ->write("end")
  | Repeat(block, expr) =>
    w
    ->write("repeat")
    ->indentThenNewline
    ->writeBlock(block)
    ->outdentThenNewline
    ->write("until (")
    ->writeExpr(expr)
    ->write(")")
  | If(((expr, block), ifElses), elseBlock) => {
      let w =
        w
        ->write("if ")
        ->writeExpr(expr)
        ->write(" then")
        ->indentThenNewline
        ->writeBlock(block)
        ->outdentThenNewline
        ->reduce(ifElses, _, (w, (expr, block)) => {
          w
          ->write("elseif ")
          ->writeExpr(expr)
          ->write(" then")
          ->indentThenNewline
          ->writeBlock(block)
          ->outdentThenNewline
        })

      switch elseBlock {
      | None => w->write("end")
      | Some(block) =>
        w->write("else")->indentThenNewline->writeBlock(block)->outdentThenNewline->write("end")
      }
    }
  | Fornum(ident, expr, expr1, expr2, block) =>
    let w =
      w
      ->write("for ")
      ->writeIdent(ident)
      ->write(" = ")
      ->writeExpr(expr)
      ->write(", ")
      ->writeExpr(expr1)

    let w = switch expr2 {
    | None => w
    | Some(expr2) => w->write(", ")->writeExpr(expr2)
    }

    w
    //
    ->write(" do")
    ->indentThenNewline
    ->writeBlock(block)
    ->outdentThenNewline
    ->write("end")

  | Forin((ident, idents), (expr, exprs), block) => {
      let w = w

      w
      ->write("for ")
      ->writeIdent(ident)
      ->reduce(idents, _, (w, t) => {
        w->write(", ")->writeIdent(t)
      })
      ->write(" in ")
      ->writeExpr(expr)
      ->reduce(exprs, _, (w, t) => {
        w->write(", ")->writeExpr(t)
      })
      ->write(" do")
      ->indentThenNewline
      ->writeBlock(block)
      ->outdentThenNewline
      ->write("end")
    }
  | Local((ident, idents), None) =>
    w
    ->write("local ")
    ->writeIdent(ident)
    ->reduce(idents, _, (w, t) => {
      w->write(", ")->writeIdent(t)
    })

  | Local((ident, idents), Some(expr, exprs)) =>
    w
    ->write("local ")
    ->writeIdent(ident)
    ->reduce(idents, _, (w, t) => {
      w->write(", ")->writeIdent(t)
    })
    ->write(" = ")
    ->writeExpr(expr)
    ->reduce(exprs, _, (w, t) => {
      w->write(", ")->writeExpr(t)
    })

  | Localrec(ident, args, dots, block) => {
      let w = w->write("local function ")->writeIdent(ident)->write("(")

      let w = switch (args, dots) {
      | (list{}, None) => w
      | (list{}, Some(dots)) => w->writeDots(dots)
      | (list{head, ...rest}, dots) =>
        let w = w->writeIdent(head)->reduce(rest, _, writeIdent)

        switch dots {
        | None => w
        | Some(dots) => w->write(", ")->writeDots(dots)
        }
      }

      let w = w->write(")")->indentThenNewline->writeBlock(block)

      w->outdentThenNewline->write("end")
    }
  | Goto(t) => w->write("goto ")->write(t)
  | Label(t) => w->write("::")->write(t)->write("::")
  | Return(list{}) => w->write("return")
  | Return(list{head, ...rest}) =>
    w
    ->write("return ")
    ->writeExpr(head)
    ->reduce(rest, _, (w, t) => {
      w->write(", ")->writeExpr(t)
    })

  | Break => w->write("break")
  | StatementApply(t) => w->writeApply(t)
  }
}

and writeDots = (w, t) => {
  switch t {
  | Dots => "..."
  }->Writer.write(w, _)
}

and writeTableElement = (w, t) => {
  switch t {
  | Pair(expr, expr1) => w->writeExpr(expr)->write(" = ")->writeExpr(expr1)
  | TableExp(t) => writeExpr(w, t)
  }
}

and writeExpr = (w, t) => {
  switch t {
  | Nil => w->Writer.write("nil")
  | ExprDots(t) => writeDots(w, t)
  | True => w->Writer.write("true")
  | False => w->Writer.write("false")
  | Number(float) => w->Writer.write(Js.Float.toString(float))
  | String(t) => w->write(`"`)->write(t)->write(`"`)
  | Function(idents, dots, block) => {
      let w = w->write("function(")
      let w = switch (idents, dots) {
      | (list{}, None) => w
      | (list{}, Some(dots)) => w->writeDots(dots)
      | (list{head, ...rest}, None) =>
        w
        ->writeIdent(head)
        ->reduce(rest, _, (w, t) => {
          w->write(", ")->writeIdent(t)
        })

      | (list{head, ...rest}, Some(dots)) =>
        w
        ->writeIdent(head)
        ->reduce(rest, _, (w, t) => {
          w->write(", ")->writeIdent(t)
        })
        ->write(", ")
        ->writeDots(dots)
      }

      w->write(")")->indentThenNewline->writeBlock(block)->outdentThenNewline->write("end")
    }
  | Table(list{}) => w->write("{}")
  | Table(list{head, ...rest}) =>
    w
    ->write("{")
    ->indentThenNewline
    ->writeTableElement(head)
    ->reduce(rest, _, (w, t) => {
      w->write(", ")->newline->writeTableElement(t)
    })
    ->outdentThenNewline
    ->write("}")
  | UnaryOp(opId, expr) => w->writeUnaryOpId(opId)->write(" ")->writeExpr(expr)
  | BinaryOp(opId, expr, expr1) =>
    w->writeExpr(expr)->write(" ")->writeBinaryOpId(opId)->write(" ")->writeExpr(expr1)
  | Paren(t) => w->write("(")->writeExpr(t)->write(")")
  | ExprApply(t) => w->writeApply(t)
  | ExprLhs(t) => w->writeLhs(t)
  }
}

and writeApply = (w, t) => {
  switch t {
  | Call(expr, list{}) => w->writeExpr(expr)->write("()")
  | Call(expr, list{head, ...rest}) =>
    w
    ->writeExpr(expr)
    ->write("(")
    ->writeExpr(head)
    ->reduce(rest, _, (w, t) => {
      w->write(", ")->writeExpr(t)
    })
    ->write(")")
  | Invoke(expr, name, list{}) => w->writeExpr(expr)->write(":")->write(name)->write("()")
  | Invoke(expr, name, list{head, ...rest}) =>
    w
    ->writeExpr(expr)
    ->write(":")
    ->write(name)
    ->write("(")
    ->writeExpr(head)
    ->reduce(rest, _, (w, t) => {
      w->write(", ")->writeExpr(t)
    })
    ->write(")")
  }
}

and writeIdent = (w, t) => {
  switch t {
  | Id(x) => x
  }->Writer.write(w, _)
}

and writeLhs = (w, t) => {
  switch t {
  | LhsIdent(t) => writeIdent(w, t)
  | Index(expr, ExprLhs(lhs)) => w->writeExpr(expr)->write(".")->writeLhs(lhs)
  | Index(expr, expr1) => w->writeExpr(expr)->write("[")->writeExpr(expr1)->write("]")
  }
}

and writeBinaryOpId = (w, t) => {
  switch t {
  | Add => "+"
  | Sub => "-"
  | Mul => "*"
  | Div => "/"
  | Mod => "%"
  | Pow => "^"
  | Concat => ".."
  | Eq => "=="
  | Lt => "<"
  | Le => "<="
  | And => "and"
  | Or => "or"
  }->Writer.write(w, _)
}
and writeUnaryOpId = (w, t) => {
  switch t {
  | Not => "not"
  | Len => "#"
  }->Writer.write(w, _)
}

let print = ast => {
  let Block(statements) = ast
  let map = Belt.List.map

  let rec write_ = t => {
    switch t {
    | list{} => ""
    | list{head, ...rest} => head ++ "\n\n" ++ write_(rest)
    }
  }

  statements->map(x => Block(list{x}))->map(writeBlock(make()))->map(toString)->write_
}
