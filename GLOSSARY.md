# Typed Model API

Typed Idris bindings for a model API, generated from JSON Schemas.

## Language

**Schema**:
A JSON Schema document that describes a data shape.
_Avoid_: input, json file, spec

**Generated source**:
Idris modules produced from schemas, not hand-written.
_Avoid_: output idr, codegen artifact

**Typegen**:
The Idris program that produces generated source from schemas.
_Avoid_: just recipe, file-at-a-time generator, json-schema executable

**Generated module**:
The Idris module that corresponds to one schema.
_Avoid_: output file, codegen unit
