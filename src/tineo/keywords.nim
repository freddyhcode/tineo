import std/strutils
import token

proc classifyWord*(word: string): TokenKind =
  let normalized = word.toUpperAscii()

  case normalized
  of "CREATE", "TABLE",
     "PRIMARY", "KEY",
     "AUTOINCREMENT", "AUTO_INCREMENT", 
     "FOREIGN", "REFERENCES", 
     "ON", "DELETE", "UPDATE", "CASCADE",
     "NOT", "NULL",
     "UNIQUE", "DEFAULT",
     "CONSTRAINT":
    return tkKeyword
  of "INT", "INTEGER",
     "VARCHAR", "TEXT",
     "BOOLEAN", "DATE":
    return tkType

  else:
    return tkIdentifier