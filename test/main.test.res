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
    (Index(ExprLhs(LhsIdent(Id("love"))), ExprLhs(LhsIdent(Id("load")))), list{}),
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
      StatementApply(Call(ExprLhs(LhsIdent(Id("print"))), list{String("world")})),
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

open Ava

test("Test", t => {
  let expected = Node.Fs.readFileAsUtf8Sync("expected.lua")
  let parse = Lua_parse.parse(_, ())
  let a = parse(Printer.print(ast))
  let b = parse(expected)

  t->deepEqual(a, b, ~message="Outputs should be identical", ())
})

let runStatementsTests = (~label, ~tests) => {
  tests->Belt.Array.forEach(((ast, expected)) => {
    test("[AST] " ++ label ++ " | " ++ expected, t => {
      let parse = Lua_parse.parse(_, ())
      let a = Writer.make()->Printer.writeStatement(ast)->Writer.toString->parse
      let b = parse(expected)

      t->deepEqual(a, b, ~message="Outputs should be identical", ())
    })
  })
}

runStatementsTests(
  ~label="Statements",
  ~tests=[
    (Do(list{}), "do end"),
    (Do(list{Set((LhsIdent(Id("foo")), list{}), (Number(1.), list{}))}), "do foo = 1 end"),
    (Set((LhsIdent(Id("foo")), list{}), (Number(1.), list{})), "foo = 1"),
    (While(BinaryOp(Lt, Number(1.), Number(2.)), Block(list{})), "while 1 < 2 do end"),
    (
      Repeat(Block(list{Do(list{})}), BinaryOp(Le, ExprLhs(LhsIdent(Id("a"))), Number(1.))),
      "repeat do end until (a <= 1)",
    ),
    (
      Set((LhsIdent(Id("a")), list{LhsIdent(Id("b"))}), (Number(1.), list{String("hello")})),
      `a, b = 1, "hello"`,
    ),
    (Return(list{}), "return"),
  ],
)
