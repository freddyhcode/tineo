import ../tineo/lexer
import ../tineo/parser
import ../tineo/token

proc debug*(source: string) =
  var lexer = initLexer(source)
  var tokens: seq[Token] = @[]

  while true:
    let token = lexer.readNext()
    tokens.add(token)

    if token.kind == tkEOF:
      break

  echo "TOKENS"
  echo tokens
  echo ""

  var parser = initParser(tokens)
  let schema = parser.parseSchema()

  echo "AST"
  echo schema