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
    (
      Set((LhsIdent(Id("a")), list{LhsIdent(Id("b"))}), (Number(1.), list{String("hello")})),
      `a, b = 1, "hello"`,
    ),
    (While(BinaryOp(Lt, Number(1.), Number(2.)), Block(list{})), "while 1 < 2 do end"),
    (
      Repeat(Block(list{Do(list{})}), BinaryOp(Le, ExprLhs(LhsIdent(Id("a"))), Number(1.))),
      "repeat do end until (a <= 1)",
    ),
    (
      If(
        (
          (
            BinaryOp(Eq, ExprLhs(LhsIdent(Id("x"))), Number(1.)),
            Block(list{Set((LhsIdent(Id("x")), list{}), (Number(2.), list{}))}),
          ),
          list{},
        ),
        None,
      ),
      "if x == 1 then x = 2 end",
    ),
    (
      If(
        (
          (
            BinaryOp(Eq, ExprLhs(LhsIdent(Id("x"))), Number(1.)),
            Block(list{Set((LhsIdent(Id("x")), list{}), (Number(2.), list{}))}),
          ),
          list{
            (
              BinaryOp(Eq, ExprLhs(LhsIdent(Id("x"))), Number(2.)),
              Block(list{Set((LhsIdent(Id("x")), list{}), (Number(3.), list{}))}),
            ),
          },
        ),
        Some(Block(list{Set((LhsIdent(Id("x")), list{}), (Number(3.), list{}))})),
      ),
      "if x == 1 then x = 2 elseif x == 2 then x = 3 else x = 3 end",
    ),
    // Fornum,
    // Forin,
    // Local,
    (Local((Id("hello"), list{}), None), "local hello"),
    (Local((Id("hello"), list{Id("world")}), None), "local hello, world"),
    (
      Local(
        (Id("hello"), list{Id("world")}),
        Some((ExprLhs(LhsIdent(Id("world"))), list{Number(1.)})),
      ),
      "local hello, world = world, 1",
    ),
    (
      Local((Id("hello"), list{Id("world")}), Some((Nil, list{Table(list{})}))),
      "local hello, world = nil, {}",
    ),
    (
      Local(
        (Id("foo"), list{}),
        Some((
          Table(list{
            //
            TableExp(Number(1.)),
            Pair(ExprLhs(LhsIdent(Id("a"))), String("b")),
          }),
          list{},
        )),
      ),
      "local foo = { 1, a = \"b\" }",
    ),
    // Localrec,
    // Goto,
    // Label
    (Return(list{}), "return"),
    (
      Return(list{
        Table(list{
          //
          Pair(ExprLhs(LhsIdent(Id("module"))), String("property")),
          Pair(ExprLhs(LhsIdent(Id("another"))), ExprLhs(LhsIdent(Id("one")))),
        }),
      }),
      "return { module = \"property\", another = one }",
    ),
    // Break
    // StatementApply
  ],
)
