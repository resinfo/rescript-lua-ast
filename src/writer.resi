type t

let make: (~newline: string=?, ~tabChars: string=?, unit) => t
let flatMap: (t, t => t) => t
let map: (t, string => string) => t
let indent: t => t
let outdent: t => t
let write: (t, string) => t
let writeLine: (t, string) => t
let newline: t => t
let indentThenNewline: t => t
let outdentThenNewline: t => t
let toString: t => string
