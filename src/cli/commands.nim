import std/os
import std/strutils

import ../tineo/ast
import ../tineo/lexer
import ../tineo/parser
import ../tineo/token

import ../tineo/renderers/markdown
import ../tineo/renderers/mermaid
import ../tineo/renderers/tree

import ./debug

const
  AppName = "tineo"
  AppVersion = "0.1.2"
  AppAuthor = "freddyhcode"

proc printVersion() =
  echo AppName, " Version ", AppVersion, " [", hostOS, ": ", hostCPU, "]"
  echo "Compiled at ", CompileDate
  echo "Copyright (c) 2026 ", AppAuthor
  echo ""
  echo "A native CLI tool written in Nim for analyzing SQL DDL schemas and generating documentation."

proc printHelp() =
  printVersion()
  echo ""
  echo "Usage:"
  echo "  tineo <file> [options]"
  echo ""
  echo "Options:"
  echo "  -md, --markdown           generate Markdown tables"
  echo "  -mdt, --markdown-tree     generate Markdown tree"
  echo "  -mmd, --mermaid           generate Mermaid diagram"
  echo "  -d, --debug               show tokens and AST"
  echo "  -h, --help                show this help"
  echo "  -v, --version             show version information"

proc printUsage(error: string = "") =
  if error == "":
    echo "Error: too many arguments."
  else:
    echo "Error: unknown option '", error, "'."

  echo ""
  printHelp()

proc parseFile(path: string): Schema =
  let source = readFile(path)

  var lexer = initLexer(source)
  var tokens: seq[Token] = @[]

  while true:
    let token = lexer.readNext()
    tokens.add(token)

    if token.kind == tkEOF:
      break

  var parser = initParser(tokens)

  return parser.parseSchema()

proc run*() =
  let args = commandLineParams()

  if args.len == 0:
    printHelp()
    return

  if args[0] in ["-h", "--help"]:
    printHelp()
    return

  if args[0] in ["-v", "--version"]:
    printVersion()
    return

  if args.len > 2:
    printUsage()
    return

  let inputPath = args[0]

  if not fileExists(inputPath):
    echo "Error: file not found '", inputPath, "'."
    return

  if inputPath.splitFile().ext.toLowerAscii() != ".sql":
    echo "Error: input file must have a '.sql' extension."
    return

  let schemaName = inputPath.extractFilename().splitFile().name

  if args.len == 1:
    let schema = parseFile(inputPath)
    echo renderTree(schema, schemaName)
    return

  case args[1]

  of "-md", "--markdown":
    let schema = parseFile(inputPath)
    let outputPath = inputPath.changeFileExt("md")

    writeFile(
      outputPath,
      renderMarkdownTables(schema, schemaName)
    )

    echo "Markdown generated: ", outputPath

  of "-mdt", "--markdown-tree":
    let schema = parseFile(inputPath)
    let outputPath = inputPath.splitFile().dir / (schemaName & "-tree.md")

    writeFile(
      outputPath,
      renderMarkdownTree(schema, schemaName)
    )

    echo "Markdown tree generated: ", outputPath

  of "-mmd", "--mermaid":
    let schema = parseFile(inputPath)
    let outputPath = inputPath.changeFileExt("mmd")

    writeFile(
      outputPath,
      renderMermaid(schema, schemaName)
    )

    echo "Mermaid generated: ", outputPath

  of "-d", "--debug":
    debug(readFile(inputPath))

  else:
    printUsage(args[1])