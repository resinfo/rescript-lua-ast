# ReScript Lua AST

This is a ReScript representation of the Lua AST as described [here](https://vitez.me/lua-ast) and [here](http://lua-users.org/wiki/MetaLuaAbstractSyntaxTree), with some minor modifications. This library is **not** a parser; rather, it can used to build Lua AST from a different AST (perhaps your own language), which can then be used to generate Lua programs with the `Printer.res` module.

## Notes

This is a work in progress, and as such hasn't been published to NPM. Once the test suite is fully fleshed out, this will be available as a library.

## Usage

```rescript
let program = "local hello, world = world, 1"

let ast = Ast.Block(list{
  Local(
    (Id("hello"), list{Id("world")}),
    Some((
      ExprLhs(LhsIdent(Id("world"))),
      list{Number(1.)},
    )),
  ),
})

Printer.print(ast) == program
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://choosealicense.com/licenses/mit/)
