open Ast

let ast = Block(list{
  Local((Id("hello"), list{}), Some(String("world"), list{})),
  Local(
    (Id("var"), list{}),
    Some(
      Table(list{
        //
        Pair(ExprLhs(LhsIdent(Id("a"))), Number(1.0)),
        TableExp(Number(2.)),
      }),
      list{},
    ),
  ),
  Set(
    (Index(ExprLhs(LhsIdent(Id("love"))), ExprLhs(LhsIdent(Id("love")))), list{}),
    (
      Function(
        list{},
        None,
        Block(list{
          Set(
            //
            (LhsIdent(Id("var")), list{}),
            (Number(12.), list{}),
          ),
        }),
      ),
      list{},
    ),
  ),
  Local((Id("v"), list{}), Some((Paren(Number(121.)), list{}))),
  Localrec(
    Id("bar"),
    list{Id("a")},
    None,
    Block(list{
      Return(list{
        UnaryOp(
          Not,
          BinaryOp(
            //
            Eq,
            ExprLhs(LhsIdent(Id("a"))),
            ExprLhs(LhsIdent(Id("a"))),
          ),
        ),
      }),
    }),
  ),
  Set(
    (Index(ExprLhs(LhsIdent(Id("love"))), ExprLhs(LhsIdent(Id("update")))), list{}),
    (
      Function(
        list{Id("dt")},
        Some(Dots),
        Block(list{
          Set(
            (LhsIdent(Id("var")), list{}),
            (
              BinaryOp(
                //
                Add,
                ExprLhs(LhsIdent(Id("var"))),
                ExprLhs(LhsIdent(Id("dt"))),
              ),
              list{},
            ),
          ),
        }),
      ),
      list{},
    ),
  ),
  Local(
    (Id("foo"), list{}),
    Some((
      ExprApply(
        Call(
          ExprLhs(LhsIdent(Id("x"))),
          list{
            Function(
              //
              list{Id("a"), Id("b")},
              None,
              Block(list{Return(list{Number(1.)})}),
            ),
          },
        ),
      ),
      list{},
    )),
  ),
  StatementApply(Invoke(ExprLhs(LhsIdent(Id("foo"))), "bar", list{Number(1.)})),
  StatementApply(
    Call(
      ExprLhs(Index(ExprLhs(LhsIdent(Id("foo"))), ExprLhs(LhsIdent(Id("bar"))))),
      list{Number(12.)},
    ),
  ),
  Local(
    (Id("x"), list{}),
    Some((
      ExprLhs(
        Index(
          ExprLhs(LhsIdent(Id("foo"))),
          ExprLhs(Index(ExprLhs(LhsIdent(Id("bar"))), ExprLhs(LhsIdent(Id("baz"))))),
        ),
      ),
      list{},
    )),
  ),
  Set(
    (LhsIdent(Id("a")), list{}),
    (
      Function(
        //
        list{Id("a")},
        None,
        Block(list{Return(list{Number(1.)})}),
      ),
      list{},
    ),
  ),
  Do(list{StatementApply(Call(ExprLhs(LhsIdent(Id("print"))), list{String("yes")}))}),
  While(
    True,
    Block(list{
      StatementApply(Call(ExprLhs(LhsIdent(Id("print"))), list{String("hello")})),
      StatementApply(Call(ExprLhs(LhsIdent(Id("print"))), list{String("yes")})),
      StatementApply(Call(ExprLhs(LhsIdent(Id("print"))), list{String("!")})),
    }),
  ),
  Fornum(
    Id("i"),
    Number(1.0),
    Number(10.),
    Some(Number(2.)),
    Block(list{
      StatementApply(
        //
        Call(
          ExprLhs(LhsIdent(Id("print"))),
          list{ExprLhs(LhsIdent(Id("i")))},
        ),
      ),
    }),
  ),
  Forin(
    (Id("i"), list{Id("v")}),
    (
      ExprApply(
        Call(
          ExprLhs(LhsIdent(Id("ipairs"))),
          //
          list{ExprLhs(LhsIdent(Id("table_name")))},
        ),
      ),
      list{},
    ),
    Block(list{
      StatementApply(
        Call(
          ExprLhs(LhsIdent(Id("print"))),
          list{
            //
            ExprLhs(LhsIdent(Id("i"))),
            ExprLhs(LhsIdent(Id("v"))),
          },
        ),
      ),
    }),
  ),
  If(
    (
      (
        True,
        Block(list{StatementApply(Call(ExprLhs(LhsIdent(Id("print"))), list{String("true")}))}),
      ),
      list{
        (
          False,
          Block(list{StatementApply(Call(ExprLhs(LhsIdent(Id("print"))), list{String("false")}))}),
        ),
      },
    ),
    Some(
      Block(list{
        //
        StatementApply(Call(ExprLhs(LhsIdent(Id("print"))), list{String("other")})),
      }),
    ),
  ),
})

Node.Fs.writeFileAsUtf8Sync("expected1.lua", Printer.print(ast))
