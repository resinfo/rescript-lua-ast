type t = {
  value: string,
  spaces: int,
  newlineChars: string,
  tabChars: string,
}

let make = (~newline="\n", ~tabChars="  ", ()) => {
  value: "",
  spaces: 0,
  newlineChars: newline,
  tabChars: tabChars,
}

let flatMap = (t, fn) => fn(t)
let map = (t, fn) => {...t, value: fn(t.value)}
let mapSpaces = (t, fn) => {...t, spaces: fn(t.spaces)}

let indent = mapSpaces(_, s => s + 1)
let outdent = mapSpaces(_, s => Js.Math.max_int(0, s - 1))
let write = (t, s) => map(t, v => v ++ s)

let writeLine = (t, string) =>
  t->write(t.newlineChars)->write(Js.String.repeat(t.spaces, t.tabChars))->write(string)

let newline = t => t->writeLine("")

let indentThenNewline = t => t->indent->newline
let outdentThenNewline = t => t->outdent->newline

let toString = t => t.value
