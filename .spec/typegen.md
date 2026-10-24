# Typegen

## Settled

- Schema directory: `schemas/` at the repo root. Humans author top-level `*.json` files there. No API fetch in this slice.
- Generated-source directory: `src/Generated/`. Generated source is committed.
- `just typegen` takes no file argument. It only wraps `pack run typegen.ipkg`.
- Typegen walks top-level `schemas/*.json` only (no recursion) and writes generated source. It does not delete stale generated source. The loop is in the Idris program, not the justfile.
- Typegen uses the json-schema **library** and writes `.idr` files straight into `src/Generated/`. It does not shell out to the `json-schema` executable.
- Names: `filmSchema.json` → `src/Generated/FilmSchema.idr`, module `Generated.FilmSchema`, top-level type `FilmSchema` (first letter of the stem uppercased). Invalid Idris identifiers fail the run.
- Typegen does not edit `typed-model-api.ipkg`. A human adds each `Generated.…` module to `modules`.
- Executable: `typegen.ipkg` at repo root, `sourcedir = "typegen"`, `typegen/Typegen.idr` / `module Typegen`.
- On a bad schema, typegen logs `malformed schema` and stops with a non-zero exit. Remaining schemas are not processed.
- Generated types do not implement `Cast` to JSON in this slice.

Testing (Hedgehog, pure API, remaining IO, fixture): `.spec/testing.md`.

## Open

None.
