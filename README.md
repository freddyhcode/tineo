# Tineo

[![Nim](https://img.shields.io/badge/Nim-2.x-blue)](https://nim-lang.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)]()

Una herramienta CLI nativa escrita en Nim para analizar definiciones de esquemas SQL DDL y generar documentación.

## Características

- Lexer y parser propios para SQL DDL
- AST para representar el esquema
- Vista de árbol
- Documentación Markdown
- Diagramas ER con Mermaid
- Modo debug para inspeccionar tokens y AST
- Sin dependencias externas

## SQL soportado

Tineo soporta actualmente un subconjunto de **SQL DDL**.

### Tipos

- `INT`
- `INTEGER`
- `VARCHAR(n)`
- `TEXT`
- `BOOLEAN`
- `DATE`

### Restricciones

- `PRIMARY KEY`
- `FOREIGN KEY`
- `NOT NULL`
- `UNIQUE`
- `DEFAULT`
- `AUTO_INCREMENT` / `AUTOINCREMENT`
- `CONSTRAINT`

### Relaciones

- `REFERENCES`
- `ON DELETE`
- `ON UPDATE`
- `CASCADE`
- `PRIMARY KEY (column1, column2)` — Claves primarias definidas a nivel de tabla.

> [!IMPORTANT]
> Tineo no pretende soportar SQL completo. Otras características de DDL todavía no forman parte del parser, como `ALTER TABLE`, `DROP TABLE`, `CREATE DATABASE`, `USE`, `CREATE INDEX` y `CHECK`.
>
> Algunas acciones y formas de restricciones de claves foráneas tampoco están soportadas actualmente, como `SET NULL`, `SET DEFAULT`, `NO ACTION` y claves foráneas compuestas.
>
> Las sentencias DML como `SELECT`, `INSERT`, `UPDATE` y `DELETE` no forman parte del objetivo del proyecto.

## Instalación

```powershell
nimble release
```

El ejecutable se genera en `bin/release`.

## Uso

```text
tineo <file> [options]
```

| Opción              | Descripción                          |
| ------------------- | ------------------------------------ |
| `tineo <file>`      | Muestra el esquema en forma de árbol |
| `tineo <file> -md`  | Genera tablas en Markdown            |
| `tineo <file> -mdt` | Genera un árbol en Markdown          |
| `tineo <file> -mmd` | Genera un diagrama ER con Mermaid    |
| `tineo <file> -d`   | Muestra los tokens y el AST          |
| `tineo -h`          | Muestra la ayuda                     |
| `tineo -v`          | Muestra la información de versión    |

## Arquitectura

```text
SQL
 ↓
Lexer
 ↓
Tokens
 ↓
Parser
 ↓
AST
 ↓
Renderers
 ├── Tree
 ├── Markdown
 └── Mermaid
```

> [!NOTE]
>
> Este proyecto fue creado con la intención de aprender y profundizar en la comprensión del **análisis léxico, parsing y construcción de ASTs**.

## Licencia

MIT
