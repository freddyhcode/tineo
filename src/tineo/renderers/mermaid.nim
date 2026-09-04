import ../ast

proc renderMermaid*(schema: Schema, schemaName: string): string =
  var output = "%% Schema: " & schemaName & "\n\n"
  output.add("erDiagram\n\n")

  # Generar tablas
  for table in schema.tables:
    output.add("    " & table.name & " {\n")

    for column in table.columns:
      var columnInfo =
        column.dataType & " " &
        column.name

      if column.primaryKey or column.name in table.primaryKey:
        columnInfo.add(" PK")

      for foreignKey in table.foreignKeys:
        if foreignKey.column == column.name:
          columnInfo.add(" FK")
          break

      output.add(
        "        " &
        columnInfo &
        "\n"
      )

    output.add("    }\n\n")

  # Generar relaciones
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