import ../ast

proc renderTree*(schema: Schema, fileName: string = ""): string =
  var output = "Schema"

  if fileName != "":
    output.add(" " & fileName)

  output.add("\n")
  
  for tableIndex, table in schema.tables:
    let isLastTable = tableIndex == schema.tables.len - 1

    if isLastTable:
      output.add("└── Table: " & table.name & "\n")
    else:
      output.add("├── Table: " & table.name & "\n")

    var prefix = "│   "

    if isLastTable:
      prefix = "    "

    for columnIndex, column in table.columns:
      let isLastColumn = columnIndex == table.columns.len - 1

      var columnInfo = column.name & " " & column.dataType

      if column.primaryKey:
        columnInfo.add(" [PK]")

      if column.notNull:
        columnInfo.add(" [NOT NULL]")

      if column.unique:
        columnInfo.add(" [UNIQUE]")

      if column.autoIncrement:
        columnInfo.add(" [AUTO_INCREMENT]")

      if column.defaultValue != "":
        columnInfo.add(" [DEFAULT " & column.defaultValue & "]")

      if isLastColumn and
         table.primaryKey.len == 0 and
         table.foreignKeys.len == 0:
        output.add(
          prefix & "└── Column: " & columnInfo & "\n"
        )
      else:
        output.add(
          prefix & "├── Column: " & columnInfo & "\n"
        )

    if table.primaryKey.len > 0:
      var primaryKeyInfo = "Primary Key: ("

      for index, columnName in table.primaryKey:
        if index > 0:
          primaryKeyInfo.add(", ")

        primaryKeyInfo.add(columnName)

      primaryKeyInfo.add(")")

      if table.foreignKeys.len == 0:
        output.add(
          prefix & "└── " & primaryKeyInfo & "\n"
        )
      else:
        output.add(
          prefix & "├── " & primaryKeyInfo & "\n"
        )

    for foreignKeyIndex, foreignKey in table.foreignKeys:
      let isLastForeignKey = foreignKeyIndex == table.foreignKeys.len - 1

      var foreignKeyInfo =
        foreignKey.column & " → " &
        foreignKey.referencedTable & "." &
        foreignKey.referencedColumn

      if foreignKey.name != "":
        foreignKeyInfo =
          foreignKey.name & " (" & foreignKeyInfo & ")"

      if foreignKey.onDelete != "":
        foreignKeyInfo.add(
          " [ON DELETE " & foreignKey.onDelete & "]"
        )

      if foreignKey.onUpdate != "":
        foreignKeyInfo.add(
          " [ON UPDATE " & foreignKey.onUpdate & "]"
        )

      if isLastForeignKey:
        output.add(
          prefix & "└── Foreign Key: " &
          foreignKeyInfo & "\n"
        )
      else:
        output.add(
          prefix & "├── Foreign Key: " &
          foreignKeyInfo & "\n"
        )

  return output