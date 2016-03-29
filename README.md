# ECMAScript Proposal: export default from

**Stage:** 1

**Author:** Lee Byron

**Specification:** http://leebyron.com/ecmascript-export-default-from/

**AST:** [ESTree.md](./ESTree.md)

**Transpiler:** See Babel's `es7.exportExtensions` option.

> NOTE: Tightly related to the [export-ns-from](https://github.com/leebyron/ecmascript-export-ns-from) proposal.

## Problem statement and rationale

The `export ___ from "module"` statements are a very useful mechanism for
building up "package" modules in a declarative way. In the ECMAScript 2015 spec,
we can:

* export through a single export with `export {x} from "mod"`
* ...optionally renaming it with `export {x as v} from "mod"`.
* We can also spread all exports with `export * from "mod"`.

These three export-from statements are easy to understand if you understand the
semantics of the similar looking import statements.

However there is an import statement which does not have corresponding
export-from statement, exporting the ModuleNameSpace object as a named export.

Example:

```js
export someIdentifier from "someModule";
export someIdentifier, { namedIdentifier } from "someModule";
```


### Current ECMAScript 2015 Modules:

Import Statement Form         | [[ModuleRequest]] | [[ImportName]] | [[LocalName]]
---------------------         | ----------------- | -------------- | -------------
`import v from "mod";`        | `"mod"`           | `"default"`    | `"v"`
`import * as ns from "mod";`  | `"mod"`           | `"*"`          | `"ns"`
`import {x} from "mod";`      | `"mod"`           | `"x"`          | `"x"`
`import {x as v} from "mod";` | `"mod"`           | `"x"`          | `"v"`
`import "mod";`               |                   |                |


Export Statement Form           | [[ModuleRequest]] | [[ImportName]] | [[LocalName]] | [[ExportName]]
---------------------           | ----------------- | -------------- | ------------- | --------------
`export var v;`                 | **null**          | **null**       | `"v"`         | `"v"`
`export default function f(){};`| **null**          | **null**       | `"f"`         | `"default"`
`export default function(){};`  | **null**          | **null**       | `"*default*"` | `"default"`
`export default 42;`            | **null**          | **null**       | `"*default*"` | `"default"`
`export {x}`;                   | **null**          | **null**       | `"x"`         | `"x"`
`export {x as v}`;              | **null**          | **null**       | `"x"`         | `"v"`
`export {x} from "mod"`;        | `"mod"`           | `"x"`          | **null**      | `"x"`
`export {x as v} from "mod"`;   | `"mod"`           | `"x"`          | **null**      | `"v"`
`export * from "mod"`;          | `"mod"`           | `"*"`          | **null**      | **null**


### Proposed addition:

Export Statement Form   | [[ModuleRequest]] | [[ImportName]] | [[LocalName]] | [[ExportName]]
---------------------   | ----------------- | -------------- | ------------- | --------------
`export v from "mod";`  | `"mod"`           | `"default"`    | **null**      | `"v"`


## Symmetry between import and export

There's a syntactic symmetry between the export-from statements and the import
statements they resemble. There is also a semantic symmetry; where import
creates a locally named binding, export-from creates an export entry.

As an existing example:

```js
import {v} from "mod";
```

If then `v` should be exported, this can be followed by an `export`. However, if
`v` is unused in the local scope, then it has introduced a name to the local
scope unnecessarily.

```js
import {v} from "mod";
export {v};
```

A single "export from" line directly creates an export entry, and does not alter
the local scope. It is *symmetric* to the similar "import from" statement.

```js
export {v} from "mod";
```

This presents a developer experience where it is expected that replacing the
word `import` with `export` will always provide this symmetric behavior.

### Proposed addition:

The proposed addition follows this same symmetric pattern:

Importing the "default" name (existing):

```js
import v from "mod";
```

Exporting that name (existing):

```js
import v from "mod";
export {v};
```

Symmetric "export from" (proposed):

```js
export v from "mod";
```

### Compound "export from" statements:

This proposal also includes the symmetric export-from for the compound imports:

Importing the "default" name as well as named export (existing):

```js
import v, { x, y as w } from "mod";
```

Exporting those names (existing):

```js
import v, { x, y as w } from "mod";
export { v, x, w };
```

Symmetric "export from" (proposed):

```js
export v, {x, y as w} from "mod";
```

> Note: The compound form must also support [export-ns-from](https://github.com/leebyron/ecmascript-export-ns-from) should both proposals be accepted:
>
> ```js
> export v, * as ns from "mod";
> ```

### Exporting a default as default:

One use case is to take the default export of an inner module and export it as
the default export of the outer module. This can be written as:

```js
export default from "mod";
```

This is symmmetric to the (existing) import form:

```js
import default from "mod";
export { default };
```

This is *not additional syntax* above what's already proposed. In fact, this is
just the `export v from "mod"` syntax where the export name happens to be
`default`. This nicely mirrors the other `export default ____` forms in both
syntax and semantics without requiring additional specification. An alteration
to an existing lookahead restriction is necessary for supporting this case.


### Table showing symmetry

Using the terminology of [Table 40][] and [Table 42][] in ECMAScript 2015, the
export-from form can be created from the symmetric import form by setting
export-from's **[[ExportName]]** to import's **[[LocalName]]** and export-from's
**[[LocalName]]** to **null**.

[Table 40]: http://www.ecma-international.org/ecma-262/6.0/#table-40
[Table 42]: http://www.ecma-international.org/ecma-262/6.0/#table-42

Statement Form                          | [[ModuleRequest]] | [[ImportName]] | [[LocalName]]  | [[ExportName]]
--------------                          | ----------------- | -------------- | -------------- | --------------
`import v from "mod";`                  | `"mod"`           | `"default"`    | `"v"`          |
<ins>`import v from "mod";`</ins>       | `"mod"`           | `"default"`    | **null**       | `"v"`
`import {x} from "mod";`                | `"mod"`           | `"x"`          | `"x"`          |
`export {x} from "mod";`                | `"mod"`           | `"x"`          | **null**       | `"x"`
`import {x as v} from "mod";`           | `"mod"`           | `"x"`          | `"v"`          |
`export {x as v} from "mod";`           | `"mod"`           | `"x"`          | **null**       | `"v"`
`import * as ns from "mod";`            | `"mod"`           | `"*"`          | `"ns"`         |
`export * from "mod";`                  | `"mod"`           | `"*"`          | **null**       | **null** (many)
