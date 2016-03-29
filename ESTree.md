This document specifies the extensions to the [ESTree ES6 AST][] types to
support the "export-default-from" proposal.


# Modules

## ExportNamedDeclaration

```js
extend interface ExportNamedDeclaration {
    specifiers: [ ExportSpecifier | ExportDefaultSpecifier ];
}
```

Extends the [ExportNamedDeclaration][], e.g., `export {foo} from "mod";` to
allow a new type of specifier: *ExportDefaultSpecifier*.

_Note: When `source` is `null`, having `specifiers` include
*ExportDefaultSpecifier* results in an invalid state._

_Note: Having `specifiers` include more than one *ExportDefaultSpecifier*
results in an invalid state._


## ExportDefaultSpecifier

```js
interface ExportDefaultSpecifier <: Node {
    type: "ExportDefaultSpecifier";
    exported: Identifier;
}
```

An exported binding `foo` in `export foo from "mod";`. The "exported" field
refers to the name exported in this module. That name is bound to the
`"default"` export from the `source` of the parent `ExportNamedDeclaration`.

[ESTree ES6 AST]: https://github.com/estree/estree/blob/master/es6.md
[ExportNamedDeclaration]: https://github.com/estree/estree/blob/master/es6.md#exportnameddeclaration
