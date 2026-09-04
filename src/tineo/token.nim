type
  TokenKind* = enum 
    tkKeyword
    tkIdentifier
    tkType
    tkSymbol
    tkNumber
    tkString
    tkEOF

  Token* = object
    kind*: TokenKind
    value*: string