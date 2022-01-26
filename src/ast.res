type nonEmpty<'a> = ('a, list<'a>)

type rec block = Block(list<statement>)

and statement =
  | Do(list<statement>)
  | Set(nonEmpty<lhs>, nonEmpty<expr>)
  | While(expr, block)
  | Repeat(block, expr)
  | If(nonEmpty<(expr, block)>, option<block>)
  | Fornum(ident, expr, expr, option<expr>, block)
  | Forin(nonEmpty<ident>, nonEmpty<expr>, block)
  | Local(nonEmpty<ident>, option<nonEmpty<expr>>)
  | Localrec(ident, list<ident>, option<dots>, block)
  | Goto(string)
  | Label(string)
  | Return(list<expr>)
  | Break
  | StatementApply(apply)

and dots = Dots

and tableElement =
  | Pair(expr, expr)
  | TableExp(expr)

and expr =
  | Nil
  | ExprDots(dots)
  | True
  | False
  | Number(float)
  | String(string)
  | Function(list<ident>, option<dots>, block)
  | Table(list<tableElement>)
  | UnaryOp(unaryOpId, expr)
  | BinaryOp(binaryOpId, expr, expr)
  | Paren(expr)
  | ExprApply(apply)
  | ExprLhs(lhs)

and apply =
  | Call(expr, list<expr>)
  | Invoke(expr, string, list<expr>)

and ident = Id(string)

and lhs =
  | LhsIdent(ident)
  | Index(expr, expr)

and binaryOpId =
  | Add
  | Sub
  | Mul
  | Div
  | Mod
  | Pow
  | Concat
  | Eq
  | Lt
  | Le
  | And
  | Or

and unaryOpId =
  | Not
  | Len
