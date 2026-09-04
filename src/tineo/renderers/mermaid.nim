import std/strutils
import ../ast

proc renderMermaid*(schema: Schema, schemaName: string): string =
  var output = "%% Schema: " & schemaName & "\n\n"
  output.add("erDiagram\n\n")

  for table in schema.tables:
    output.add("    " & table.name & " {\n")

    for column in table.columns:
      var dataType = column.dataType

      if "(" in dataType:
        dataType = dataType.split("(")[0]

      output.add(
        "        " &
        dataType.toLowerAscii() &
        " " &
        column.name &
        "\n"
      )

    output.add("    }\n\n")

  for table in schema.tables:
    for foreignKey in table.foreignKeys:
      output.add(
        "    " &
        foreignKey.referencedTable &
        " ||--o{ " &
        table.name &
        " : has\n"
      )

  return output