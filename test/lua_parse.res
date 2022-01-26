type ast

@ocaml.doc("**#none**

Source code characters all pass through as-is and string literals are not interpreted at all; the string literal nodes contain the value null. This is the default mode.

**#\"x-user-defined\"**

Source code has been decoded with the WHATWG x-user-defined encoding; escapes of bytes in the range [0x80, 0xff] are mapped to the Unicode range [U+F780, U+F7FF].

**#\"pseudo-latin1\"**

Source code has been decoded with the IANA iso-8859-1 encoding; escapes of bytes in the range [0x80, 0xff] are mapped to Unicode range [U+0080, U+00FF]. Note that this is not the same as how WHATWG standards define the iso-8859-1 encoding, which is to say, as a synonym of windows-1252.")
type encodingMode = [
  | #none
  | #"x-user-defined"
  | #"pseudo-latin1"
]

type luaVersion = [#"5.1" | #"5.2" | #"5.3" | #LuaJIT]

type options
@ocaml.doc("
  `wait: false` Explicitly tell the parser when the input ends.

  `comments: true` Store comments as an array in the chunk object.

  `scope: false` Track identifier scopes.

  `locations: false` Store location information on each syntax node.

  `ranges: false` Store the start and end character locations on each syntax node.

  `luaVersion: '5.1'` The version of Lua the parser will target; supported values are '5.1', '5.2', '5.3' and 'LuaJIT'.
  
  `extendedIdentifiers: false` Whether to allow code points ≥ U+0080 in identifiers, like LuaJIT does. Note: setting luaVersion: 'LuaJIT' currently does not enable this option; this may change in the future.

  `encodingMode: 'none'` Defines the relation between code points ≥ U+0080 appearing in parser input and raw bytes in source code, and how Lua escape sequences in JavaScript strings should be interpreted. See the Encoding modes section for more information.")
@obj
external options: (
  ~wait: bool=?,
  ~comments: bool=?,
  ~scope: bool=?,
  ~locations: bool=?,
  ~ranges: bool=?,
  ~luaVersion: luaVersion=?,
  ~extendedIdentifiers: bool=?,
  ~encodingMode: encodingMode=?,
  unit,
) => options = ""

@module("luaparse") @val
external parse: (string, ~options: options=?, unit) => ast = "parse"

@scope("JSON") @val
external stringifyAst: ast => string = "stringify"
