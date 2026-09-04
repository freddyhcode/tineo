type
  Column* = object
    name*: string
    dataType*: string
    notNull*: bool
    primaryKey*: bool
    autoIncrement*: bool
    unique*: bool
    defaultValue*: string
    
  ForeignKey* = object
    name*: string
    column*: string
    referencedTable*: string
    referencedColumn*: string
    onDelete*: string
    onUpdate*: string

  Table* = object
    name*: string
    columns*: seq[Column]
    foreignKeys*: seq[ForeignKey]
    primaryKey*: seq[string]
    
  Schema* = object 
    tables*: seq[Table]