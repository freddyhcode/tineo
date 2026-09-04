import std/strutils
import token
import keywords

type
  Lexer* = object
    source*: string
    position*: int

proc initLexer*(source: string): Lexer =
  return Lexer(
    source: source,
    position: 0
  )

proc currentChar*(lexer: Lexer): char =
  return lexer.source[lexer.position]

proc advance*(lexer: var Lexer): char =
  let character = lexer.source[lexer.position]

  lexer.position += 1

  return character

proc hasNext*(lexer: Lexer): bool =
  if lexer.position < lexer.source.len:
    return true

  return false

proc skipWhitespace*(lexer: var Lexer) =
  while lexer.hasNext():
    case lexer.currentChar()
    of ' ', '\n', '\t', '\r':
      discard lexer.advance()
    else:
      return

proc isLetter*(character: char): bool =
  return isAlphaAscii(character)

proc isNumber*(character: char): bool =
  return isDigit(character)

proc readWord*(lexer: var Lexer): string =
  lexer.skipWhitespace()

  var word = ""

  while lexer.hasNext() and (isLetter(lexer.currentChar()) or isNumber(lexer.currentChar()) or lexer.currentChar() == '_'):
    word.add(lexer.advance())

  return word

proc readNumber*(lexer: var Lexer): string =
  var number = ""

  while lexer.hasNext() and isNumber(lexer.currentChar()):
    number.add(lexer.advance())

  return number

proc readSymbol*(lexer: var Lexer): char =
  return lexer.advance()

proc readNext*(lexer: var Lexer): Token =
  lexer.skipWhitespace()

  if not lexer.hasNext():
    return Token(
      kind: tkEOF,
      value: ""
    )

  if isLetter(lexer.currentChar()):
    let word = lexer.readWord()
    let kind = classifyWord(word)

    return Token(
      kind: kind,
      value: word
    )
  
  if isNumber(lexer.currentChar()):
    return Token(
      kind: tkNumber,
      value: lexer.readNumber()
    )

  return Token(
    kind: tkSymbol,
    value: $lexer.readSymbol()
  )
