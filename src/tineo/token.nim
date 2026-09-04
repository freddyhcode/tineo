type
  TokenKind* = enum 
    tkKeyword
    tkIdentifier
    tkType
    tkSymbol
    tkNumber
    tkEOF

  Token* = object
    kind*: TokenKind
    value*: string