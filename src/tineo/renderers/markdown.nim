import ../ast

proc renderMarkdownTree*(schema: Schema, schemaName: string): string =
  var output = "# Schema: " & schemaName & "\n\n"

  for table in schema.tables:
    output.add("## " & table.name & "\n\n")

    for column in table.columns:
      output.add(
        "- `" & column.name & "` " &
        column.dataType & "\n"
      )

      if column.primaryKey:
        output.add("  - PK\n")

      if column.notNull:
        output.add("  - NOT NULL\n")

      if column.unique:
        output.add("  - UNIQUE\n")

      if column.autoIncrement:
        output.add("  - AUTO_INCREMENT\n")

      if column.defaultValue != "":
        output.add(
          "  - DEFAULT " &
          column.defaultValue &
          "\n"
        )

    if table.primaryKey.len > 0:
      output.add("- Primary Key: `(")

      for index, columnName in table.primaryKey:
        if index > 0:
          output.add(", ")

        output.add(columnName)

      output.add(")`\n")

    for foreignKey in table.foreignKeys:
      output.add(
        "- Foreign Key: `" &
        foreignKey.column &
        "` → `" &
        foreignKey.referencedTable &
        "." &
        foreignKey.referencedColumn &
        "`\n"
      )

      if foreignKey.name != "":
        output.add(
          "  - CONSTRAINT " &
          foreignKey.name &
          "\n"
        )

      if foreignKey.onDelete != "":
        output.add(
          "  - ON DELETE " &
          foreignKey.onDelete &
          "\n"
        )

      if foreignKey.onUpdate != "":
        output.add(
          "  - ON UPDATE " &
          foreignKey.onUpdate &
          "\n"
        )

    output.add("\n")

  return output


proc renderMarkdownTables*(
  schema: Schema,
  schemaName: string
): string =
  var output = "# Schema: " & schemaName & "\n\n"

  for table in schema.tables:
    output.add("## " & table.name & "\n\n")

    output.add(
      "| Column | Type | PK | FK | Not Null | Unique | Auto Increment | Default |\n"
    )

    output.add(
      "|---|---|---|---|---|---|---|---|\n"
    )

    for column in table.columns:
      let primaryKey =
        if column.primaryKey or column.name in table.primaryKey:
          "✓"
        else:
          ""
          
      var foreignKey = ""

      for relation in table.foreignKeys:
        if relation.column == column.name:
          foreignKey = "✓"
          break

      let notNull =
        if column.notNull:
          "✓"
        else:
          ""

      let unique =
        if column.unique:
          "✓"
        else:
          ""

      let autoIncrement =
        if column.autoIncrement:
          "✓"
        else:
          ""

      output.add(
        "| `" & column.name & "` | " &
        column.dataType & " | " &
        primaryKey & " | " &
        foreignKey & " | " &
        notNull & " | " &
        unique & " | " &
        autoIncrement & " | " &
        column.defaultValue & " |\n"
      )

    output.add("\n")

  return output