# Testing

Hedgehog is the test runner for this repo. Implementation slices: GitHub issues #3–#9.

## Settled

- Hedgehog runs `typegen-test` and `typed-model-api-test`. It is a **test-only** dependency from the pack collection (`test.ipkg` `depends`), not a library dependency of `typegen.ipkg` or `typed-model-api.ipkg`. Do not pin a custom git commit in `pack.toml` unless the collection package fails to build.
- Properties only: named `property1` scenarios, no `forAll` in this work, no `PrimIO` to fake IO inside `PropertyT`.
- Pure Typegen API, exported from `Typegen` (no new module). Production and tests share one pipeline:
  - `schemaFiles : List String -> List String` — keep `*.json`, sort
  - `compileOne : (filename : String) -> (jsonText : String) -> Either String String` — `fromFilename`, parse, `compileSchema`, `namedSource`; `Right` is generated source text
  - `compileAll : List (String, String) -> Either String (List (String, String))` — fail-fast over `(filename, jsonText)`; `Right` pairs are `(moduleLast, source)`
  - Every `Left` is `"malformed schema"`
- `runTypegen` is the IO wrapper (create dir, `listDir`, read/write). `processOne` / `processAll` call the pure functions.
- Remaining typegen **IO** (exactly four): create generated-source directory when missing; leftover generated source is not deleted; overwrite existing generated source; `just typegen`. Nested-directory ignore is `schemaFiles` (a name without `.json` drops), not an IO scenario.
- `typegen-test` is one executable, two phases: remaining IO first (must succeed), then `Hedgehog.test [ MkGroup … ]`. Hedgehog runs the whole Group. Typegen itself still fail-fasts on the first malformed schema.
- Minimize with a **table** of named cases mapped to `property1`s, not copy-pasted blocks.
- Fixture: `schemas/filmSchema.json` (same shape as the current typegen test literal) → committed `src/Generated/FilmSchema.idr` → human adds `Generated.FilmSchema` to `typed-model-api.ipkg`. After the fixture exists, the `just typegen` IO test is: succeeds on the committed schemas and does not log `malformed schema` (not “empty schemas”).
- `typed-model-api-test` is Hedgehog-only (`main = test [ MkGroup … ]`). Properties are constructibility `property1`s against `Generated.FilmSchema` (module loads / constructor applies; primitive field `===` only where `Eq`/`Show` already exist on the field type). Do not add `Eq` / `Show` / `Cast` to generated source. No random `forAll` records. JSON round-trips wait for Cast.
- Success bar for the AGENTS implementer instruction: `pack test typegen` and `pack test typed-model-api` green, **and** fewer Idris lines in `typegen/test/src` plus `test/src` than before the refactor. On success, add the pattern to `AGENTS.md` under `[<for any worktree>::implementer]`. On failure of the line-count bar, do not write that instruction.
- No `just typegen && git diff` in this work. The CI gate into `dev` is a later grill already noted on `AGENTS.md`.

## Open

None.
