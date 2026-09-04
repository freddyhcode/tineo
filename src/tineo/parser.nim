import token
import ast
import std/strutils

type
  Parser* = object
    tokens*: seq[Token]
    position*: int

proc initParser*(tokens: seq[Token]): Parser =
  return Parser(
    tokens: tokens,
    position: 0
  )

proc currentToken*(parser: Parser): Token =
  return parser.tokens[parser.position]

proc advance*(parser: var Parser): Token =
  let token = parser.tokens[parser.position]
  parser.position += 1
  return token

proc expect*(parser: var Parser, kind: TokenKind, value: string) =
  let token = parser.currentToken()

  if token.kind != kind or token.value != value:
    raise newException(
      ValueError,
      "Unexpected token: " & token.value
    )

  discard parser.advance()

proc expectKeyword*(parser: var Parser, value: string) =
  let token = parser.currentToken()

  if token.kind != tkKeyword or
    token.value.toUpperAscii() != value.toUpperAscii():
    raise newException(
      ValueError,
      "Unexpected token: " & token.value
    )

  discard parser.advance()

proc parseColumn*(parser: var Parser): Column =
  let nameToken = parser.advance()

  if nameToken.kind != tkIdentifier:
    raise newException(
      ValueError,
      "Expected column name"
    )

  let typeToken = parser.advance()

  if typeToken.kind != tkType:
    raise newException(
      ValueError,
      "Expected column type"
    )

  var dataType = typeToken.value

  if parser.currentToken().kind == tkSymbol and parser.currentToken().value == "(":

    parser.expect(tkSymbol, "(")

    let sizeToken = parser.advance()

    if sizeToken.kind != tkNumber:
      raise newException(
        ValueError,
        "Expected type size"
      )

    parser.expect(tkSymbol, ")")

    dataType = dataType & "(" & sizeToken.value & ")"

  var primaryKey = false
  var autoIncrement = false
  var notNull = false
  var unique = false
  var defaultValue = ""

  while parser.currentToken().kind == tkKeyword:
    let value = parser.currentToken().value.toUpperAscii()

    case value
    of "PRIMARY":
      parser.expectKeyword("PRIMARY")
      parser.expectKeyword("KEY")
      primaryKey = true

    of "AUTOINCREMENT", "AUTO_INCREMENT":
      discard parser.advance()
      autoIncrement = true

    of "NOT":
      parser.expectKeyword("NOT")
      parser.expectKeyword("NULL")
      notNull = true

    of "UNIQUE":
      parser.expectKeyword("UNIQUE")
      unique = true

    of "DEFAULT":
      parser.expectKeyword("DEFAULT")

      let defaultToken = parser.advance()
      defaultValue = defaultToken.value

    else:
      break

  return Column(
    name: nameToken.value,
    dataType: dataType,
    primaryKey: primaryKey,
    autoIncrement: autoIncrement,
    notNull: notNull,
    unique: unique,
    defaultValue: defaultValue
  )

proc parseTable*(parser: var Parser): Table =
  parser.expectKeyword("CREATE")
  parser.expectKeyword("TABLE")

  let nameToken = parser.advance()

  if nameToken.kind != tkIdentifier:
    raise newException(
      ValueError,
      "Expected table name"
    )

  parser.expect(tkSymbol, "(")

  var columns: seq[Column] = @[]
  var foreignKeys: seq[ForeignKey] = @[]
  var primaryKey: seq[string] = @[]

  while not (parser.currentToken().kind == tkSymbol and parser.currentToken().value == ")"):

    let token = parser.currentToken()
    let value = token.value.toUpperAscii()

    if token.kind == tkKeyword and (value == "FOREIGN" or value == "CONSTRAINT"):
      var constraintName = ""
      var onDelete = ""
      var onUpdate = ""
      
      if value == "CONSTRAINT":
        parser.expectKeyword("CONSTRAINT")

        let constraintNameToken = parser.advance()

        if constraintNameToken.kind != tkIdentifier:
          raise newException(
            ValueError,
            "Expected constraint name"
          )

        constraintName = constraintNameToken.value

      parser.expectKeyword("FOREIGN")
      parser.expectKeyword("KEY")

      parser.expect(tkSymbol, "(")

      let columnToken = parser.advance()

      if columnToken.kind != tkIdentifier:
        raise newException(
          ValueError,
          "Expected foreign key column"
        )

      parser.expect(tkSymbol, ")")

      parser.expectKeyword("REFERENCES")

      let tableToken = parser.advance()

      if tableToken.kind != tkIdentifier:
        raise newException(
          ValueError,
          "Expected referenced table"
        )

      parser.expect(tkSymbol, "(")

      let referencedColumnToken = parser.advance()

      if referencedColumnToken.kind != tkIdentifier:
        raise newException(
          ValueError,
          "Expected referenced column"
        )

      parser.expect(tkSymbol, ")")


      while parser.currentToken().kind == tkKeyword and parser.currentToken().value.toUpperAscii() == "ON":
        
        parser.expectKeyword("ON")

        let actionTypeToken = parser.advance()

        if actionTypeToken.kind != tkKeyword:
          raise newException(
            ValueError,
            "Expected foreign key action type"
          )

        let actionType = actionTypeToken.value.toUpperAscii()

        let actionToken = parser.advance()

        if actionToken.kind != tkKeyword:
          raise newException(
            ValueError,
            "Expected foreign key action"
          )
        
        if actionType == "DELETE":
          onDelete = actionToken.value
        elif actionType == "UPDATE":
          onUpdate = actionToken.value
        else:
          raise newException(
            ValueError,
            "Expected DELETE or UPDATE"
          )

      foreignKeys.add(
        ForeignKey(
          column: columnToken.value,
          referencedTable: tableToken.value,
          referencedColumn: referencedColumnToken.value,
          onDelete: onDelete,
          onUpdate: onUpdate
        )
      )

    elif token.kind == tkKeyword and value == "PRIMARY":
      parser.expectKeyword("PRIMARY")
      parser.expectKeyword("KEY")

      parser.expect(tkSymbol, "(")

      while true:
        let columnToken = parser.advance()

        if columnToken.kind != tkIdentifier:
          raise newException(
            ValueError,
            "Expected primary key column"
          )

        primaryKey.add(columnToken.value)

        if parser.currentToken().kind == tkSymbol and
          parser.currentToken().value == ",":
          parser.expect(tkSymbol, ",")
        else:
          break

      parser.expect(tkSymbol, ")")

    else:
      columns.add(parser.parseColumn())

    if parser.currentToken().kind == tkSymbol and
      parser.currentToken().value == ",":
      parser.expect(tkSymbol, ",")

  parser.expect(tkSymbol, ")")

  return Table(
    name: nameToken.value,
    columns: columns,
    foreignKeys: foreignKeys,
    primaryKey: primaryKey
  )

proc parseSchema*(parser: var Parser): Schema =
  var tables: seq[Table] = @[]

  while parser.currentToken().kind != tkEOF:
    let table = parser.parseTable()
    tables.add(table)

    if parser.currentToken().kind == tkSymbol and
      parser.currentToken().value == ";":
      parser.expect(tkSymbol, ";")

  return Schema(
    tables: tables
  )