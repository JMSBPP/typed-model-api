# Does Idris 2 support QuickSpec-like test strategies?

**Answer: no.** Idris 2 has no QuickSpec-style automatic equational-law discovery from a function signature. What exists today is (1) programmer-written property tests with random generation and integrated shrinking (`hedgehog`), (2) programmer-written unit tests (`tester`, `simple-tests`, `control-spec`), (3) golden-file / CLI output tests (`test` / `Test.Golden`, wiki-listed `replica`), (4) generator derivation without a full property runner (`deptycheck`), and (5) Idris-native proofs and totality as an alternative to testing laws. None of those discover equations.

QuickSpec is not QuickCheck. QuickSpec *invents* candidate equations from a signature and keeps those that survive random tests. QuickCheck (and Hedgehog) *check* properties the programmer already wrote. That distinction is the owners' own wording, cited below.

This is a research note against primary sources only (Hackage, first-party GitHub/GitLab/READMEs/`.ipkg` files, first-party papers, official Idris 2 docs/repo, the installed pack collection, and this workspace). It is not an implementation plan.

---

## A. What QuickSpec actually is (owners' claims)

### Hackage and GitHub README

Hackage package `quickspec` (current version 2.2.2, uploaded 2026-08-27 by Nick Smallbone; category Testing; homepage <https://github.com/nick8325/quickspec>):

> QuickSpec takes your Haskell code and, as if by magic, discovers laws about it. You give QuickSpec a collection of Haskell functions; QuickSpec tests your functions with QuickCheck and prints out laws which seem to hold.
>
> QuickSpec can find equational laws as well as conditional equations. All you need to supply are the functions to test, as well as `Ord` and `Arbitrary` instances for QuickSpec to use in testing; the rest is automatic.

Source: <https://hackage.haskell.org/package/quickspec> (package description, duplicated in the tarball README). The same paragraph is the GitHub README at <https://github.com/nick8325/quickspec/blob/master/README.md>.

The example they give is the whole point: given `reverse`, `(++)`, and `[]`, QuickSpec prints six laws (`reverse [] == []`, unit laws for `++`, associativity, `reverse (reverse xs) == xs`, and `reverse xs ++ reverse ys == reverse (ys ++ xs)`). The programmer does not write those equations.

Hackage Haddock for `QuickSpec` (<https://hackage.haskell.org/package/quickspec-2.2/docs/QuickSpec.html>) names the input a *signature*: a list of functions declared with `con`, optional Boolean *predicates* declared with `predicate` (for conditional equations), plus `Ord`/`Arbitrary` (or `Observe`) instances. `quickSpec sig` then "test[s] it and see[s] the discovered equations." Custom types need `monoType` or `inst`. The module points at the paper "Quick specifications for the busy programmer" (<http://www.cse.chalmers.se/~nicsma/papers/quickspec2.pdf>).

Dependencies on Hackage include `QuickCheck >= 2.14.2` and `twee-lib == 2.7.1`. QuickSpec *uses* QuickCheck as a tester; it is not a QuickCheck clone.

### TAP 2010 paper (QuickSpec 1)

Koen Claessen, Nicholas Smallbone, John Hughes, "QuickSpec: Guessing Formal Specifications using Testing", Tests and Proofs 2010. First-party PDF: <https://smallbone.se/papers/quickspec.pdf>.

Abstract: "We present QuickSpec, a tool that automatically generates algebraic specifications for sets of pure functions. The tool is based on testing, rather than static analysis or theorem proving."

The introduction states the contrast with QuickCheck in the authors' own words:

> Our earlier work on the random testing tool QuickCheck [2] follows this direction. However, coming up with formal specifications is difficult… We propose an automatic method that, given a list of function names and their object code, uses testing to come up with a set of algebraic equations that seem to hold for those functions.

They are explicit that the method is *potentially unsound* (equations might fail to hold if the test data are weak) but *complete in a precise sense* up to a term-size bound: any syntactically valid equation that actually holds can be derived from the generated set. The 2010 implementation targets Haskell and Erlang, "purely functional code, i.e. no side effects."

Method (section "The method"): (1) generate a finite universe of terms; (2) partition by testing into equivalence classes; (3) generate equations from those classes; (4) prune equations that follow from others by equational reasoning.

### JFP 2017 paper (QuickSpec 2)

Nicholas Smallbone, Moa Johansson, Koen Claessen, Maximilian Algehed, "Quick specifications for the busy programmer", *Journal of Functional Programming* 27 (2017), doi:10.1017/S0956796817000090. First-party PDF: <https://www.cse.chalmers.se/~jomoa/papers/quickspec-JFP.pdf> (same paper as the README's `quickspec2.pdf`).

Abstract: "QuickSpec is a theory exploration system which tests a Haskell program to find equational properties of it, automatically. … QuickSpec is largely automatic: the user just supplies the functions to be tested and QuickCheck data generators."

The paper again distinguishes writing properties (hard) from discovering them (what QuickSpec does), and lists uses: confirming/denying expectations, regression tests, refinement of a model implementation, understanding third-party code, and feeding conjectures to inductive provers HipSpec and Hipster. It does **not** mention Idris.

### Related first-party theory-exploration work (not Idris)

These are first-party papers by the same group, listed so they are not mistaken for Idris support:

- HipSpec (Claessen, Johansson, Rosén, Smallbone, CADE 2013): <https://www.cse.chalmers.se/~jomoa/papers/hipspec-cade.pdf> — Haskell theory exploration *plus proving*.
- Hipster (Johansson, Rosén, Smallbone, Claessen, CICM 2014): theory exploration inside Isabelle/HOL, not Idris.
- "Conjectures, Tests and Proofs: An Overview of Theory Exploration" (VPT 2021): <https://www.cse.chalmers.se/~jomoa/papers/VPT21QuickSpec.pdf> / <https://smallbone.se/papers/conjectures-tests-and-proofs.pdf>.
- Haskell Speculate (Rudy Matela, inspired by QuickSpec, enumerative via LeanCheck): <https://github.com/rudymatela/speculate> — "Speculate automatically discovers laws about Haskell functions." Not Idris.
- Coq Rooster-Spec (Mikkel Milo): <https://github.com/mikkelmilo/rooster-spec> — "Automated Theory Exploration in Coq using Haskell's QuickSpec" via extraction. Not Idris.

`gh search repos quickspec` (2026-10-24) returned Haskell QuickSpec, Coq Rooster-Spec, Haskell easyspec, JS fast-spec, and unrelated homonyms. No Idris repository.

---

## The five strategies, named so they stay distinct

| # | Strategy | Who writes the property? | How is it checked? | Exists for Idris 2? |
|---|----------|--------------------------|--------------------|---------------------|
| 1 | **QuickSpec-style** | Nobody: equations are *discovered* from a signature | Random testing of candidate equations, then pruning | **No** (searched; see absences) |
| 2 | **QuickCheck-style** | Programmer | Random generation, shrinking | Partial: Idris 1 port only; Idris 2 uses Hedgehog instead |
| 3 | **SmallCheck / LeanCheck-style** | Programmer | Exhaustive / enumerative generation | **No** Idris package found |
| 4 | **Hedgehog-style** | Programmer | Integrated shrinking generators | **Yes**: `stefan-hoeck/idris2-hedgehog`, in pack |
| 5 | **Idris-native proofs / totality** | Programmer writes a type and a total term | Type checker + totality checker | **Yes**: language feature, official docs |

---

## B. Idris 2 official docs and the Idris2 repo

Official docs index: <https://idris2.readthedocs.io/en/latest/>. Sections include a crash course, FAQ, packages, theorem proving, FFI, cookbook. There is **no** page on QuickSpec, QuickCheck, Hedgehog, property-based testing, or law discovery. Searched: `site:idris2.readthedocs.io testing OR Test.Golden OR hedgehog OR QuickCheck`. Hits were "Testing" examples in the well-typed interpreter tutorial (hand-written `Expr` values) and theorem-proving / `failing` blocks, not a testing library.

### Compiler-shipped `test` package: golden files only

Repo: <https://github.com/idris-lang/Idris2>. Libraries listed in `libs/` are `prelude`, `base`, `contrib`, `linear`, `network`, `papers`, `test` (<https://github.com/idris-lang/Idris2/tree/main/libs>). `libs/test/test.ipkg` declares a single module: `Test.Golden`.

`libs/test/README.md` (<https://github.com/idris-lang/Idris2/blob/main/libs/test/README.md>) says:

> Currently the package contains one module facilitating one style of testing: `Golden`. Contributions containing other modules that enable additional testing styles are encouraged.
>
> Golden facilitates testing by way of comparing a test's output to a predetermined expectation.

That is output-diff testing (a `run` script plus an `expected` file), not property testing and not law discovery. The same README notes "in a language like Idris 2, there are a number of strategies one can take for testing" and that the *eventual* goal is a blend; today only Golden is there.

Installed copy on this machine: `/home/jmsbpp/.local/idris2-bootstrap/idris2-0.8.0/test-0.8.0/Test/Golden.idr`. Module header: "Core features required to perform Golden file testing."

The compiler's own `tests/` directory (<https://github.com/idris-lang/Idris2/blob/main/tests/README.md>) is the same golden harness (`run` + `expected`), documented as testing the type checker and compiler.

### `contrib/Test` is a redirect, not a unit/property framework

GitHub API listing of `libs/contrib/Test` on `main` contains **one file**, `REDIRECT.md` (<https://raw.githubusercontent.com/idris-lang/Idris2/main/libs/contrib/Test/REDIRECT.md>):

> Where did contrib's `Test.Golden` go? You can find the same module as part of the new `test` package.

There is no `Test.Unit`, no `Test.QuickCheck`, no property combinators in Idris 2 contrib.

### Historical CONTRIBUTING.md: no in-tree unit/property framework

At commit `d9cc448d3eb0523493b0ca01fcff6816d94813a1`, `CONTRIBUTING.md` listed under "Things that should be discussed via the issue tracker first":

> A new approach to testing libraries: we don't have a unit testing or property testing framework as part of the Idris system, itself, though it would be valuable for testing the prelude and base libraries. This would be nice to have, so proposals are welcome.

Current `CONTRIBUTING.md` on `main` (<https://raw.githubusercontent.com/idris-lang/Idris2/main/CONTRIBUTING.md>, fetched 2026-10-24) has been rewritten and **no longer contains that paragraph**. It still says the `tests/` subdirectory "is intended for testing the type checker and compiler, not specifically for testing libraries. However, we do need a better way of testing libraries!" It does not claim a QuickSpec-like tool exists.

### Official wiki: third-party testing = Hedgehog + replica

<https://github.com/idris-lang/Idris2/wiki/Third-party-Libraries> (edited 2025-11-27), section **Testing**:

| Package | Description | Repository |
|---------|-------------|------------|
| hedgehog | A property based testing library with integrated shrinking | stefan-hoeck/idris2-hedgehog |
| replica | A golden value based testing executable | berewt/replica |

No QuickSpec, QuickCheck, SmallCheck, LeanCheck, specdris, or tasty. Replica's own README (<https://github.com/ReplicaTest/REPLica>, fetched as `berewt/replica` redirect) describes "Golden tests for Command Line interfaces" inspired by Idris 2's test suite. Replica is **not** in the installed pack collection `nightly-260921` (see absences).

### Proofs and totality (Idris-native alternative to testing laws)

Official tutorial "Theorem Proving": <https://idris2.readthedocs.io/en/latest/tutorial/theorems.html>. Equality is `data Equal` / `x = y` with constructor `Refl`. "A proof, as far as we are concerned here, is merely a program with a precise enough type to guarantee a particular property of interest." Totality is required to trust proofs: a total function must cover all inputs, be well-founded, use strictly positive data, and not call non-total functions. `%default total` and `--total` exist.

`failing` blocks (<https://idris2.readthedocs.io/en/stable/reference/failing.html>) check that code is *rejected* by elaboration. That is negative type-checking, not random testing and not law discovery.

Hedgehog's own tutorial (first-party, Idris 2) makes the same contrast from the testing-library side. `docs/src/Docs/Intro.md` in `idris2-hedgehog`:

> To give a first example of the capabilities of this library, we verify that reversing a list twice will lead to the original list. This is - of course - completely pointless in Idris, since Idris can prove this at compile time.

So the Idris 2 ecosystem's own property-testing docs treat compile-time proof as the preferred way to establish laws like `reverse (reverse xs) = xs`, and treat Hedgehog as useful when functions "are not reduced during unification" (their example: `fastPack` / `fastUnpack`).

---

## C. Pack collection / community packages

Local pack (this machine, 2026-10-24):

- Collection: `nightly-260921`
- Idris 2: 0.8.0, commit `1c630e67c386629a0fbbc6b78a59176fde7f0a76` from <https://github.com/idris-lang/Idris2>
- Pack commit: `6baee7d5d59a93cf147de7b1208a2ad934645673`
- DB file: `/home/jmsbpp/.local/state/pack/db/nightly-260921.toml`
- Installed libraries in this collection: `base`, `collie`, `contrib`, `idris2`, `json-schema`, `linear`, `network`, `prelude`
- Hedgehog is **not** installed here (it is in the collection, `pack query hedgehog` finds it)

Upstream collections: <https://github.com/stefan-hoeck/idris2-pack-db> (`collections/HEAD.toml`) and status page <https://stefan-hoeck.github.io/idris2-pack-db/>. Pack itself: <https://github.com/stefan-hoeck/idris2-pack>.

### `pack query` results (collection `nightly-260921`)

| Query string | Hits | Notes |
|--------------|------|-------|
| `quickspec` | *(empty)* | no package |
| `quickcheck` | *(empty)* | no package |
| `specdris` | *(empty)* | no package |
| `tasty` | *(empty)* | no package |
| `leancheck` | *(empty)* | no package |
| `smallcheck` | *(empty)* | no package |
| `unit-test` | *(empty)* | no package |
| `property` | *(empty)* | no package |
| `law` | *(empty)* | no package |
| `replica` | *(empty)* | wiki-listed, not in this collection |
| `hedgehog` | `hedgehog`, `bounded-doubles-hedgehog-generators`, `evince-hedgehog` | property testing + two generator add-ons |
| `spec` | `async-spec`, `control-spec` | unit/async test frameworks, not law discovery |
| `test` | `bytestring`, `simple-tests`, `test`, `tester`, plus this repo's local `typed-model-api-test` / `typegen-test` | substring match |

HEAD.toml (`stefan-hoeck/idris2-pack-db`, fetched 2026-10-24) was grepped for `replica`, `quickspec`, `leancheck`, `smallcheck`, `specdris`, `quickcheck`: **no matches**.

### Concrete Idris 2 packages (with status)

**hedgehog** — QuickCheck-*spirit* / Hedgehog-style, **not** QuickSpec.

- Repo: <https://github.com/stefan-hoeck/idris2-hedgehog>
- Pack: `[db.hedgehog]` in `nightly-260921.toml`, url as above, `ipkg = hedgehog.ipkg`, `test = tests/tests.ipkg`, commit `f413d4bb7010063dedb15f29839accbc0617c4d4`
- GitHub `pushed_at`: 2026-07-05 (maintained)
- `hedgehog.ipkg` brief: "A property based testing library with integrated shrinking"; version 0.6.0
- README: "An Idris port of the Haskell Hedgehog library, a property-based testing library in the spirit of QuickCheck." Features: monadic generators with integrated shrinking, SOP generic generators, coverage/`classify`. Limitations include "**No automatic detection of properties in source files (yet).**" Differences vs QuickCheck: no `Arbitrary` (generators are written, often via SOP); shrinking is integrated.
- API: `Hedgehog.Internal.Property` exports `forAll : Show a => Gen a -> PropertyT a` and `property : PropertyT () -> Property`. The programmer writes the body of the property; Hedgehog generates inputs and shrinks failures. That is strategy 4, not strategy 1.
- Tutorial explicitly writes `xs === reverse (reverse xs)` by hand.

**deptycheck** — generator derivation for dependent types; properties "lacking".

- Repo: <https://github.com/buzden/deptycheck>
- Docs: <https://deptycheck.readthedocs.io>
- Pack: `[db.deptycheck]`, commit `3b2467c6b22a7a0e01795bb3776354219558d747`
- GitHub `pushed_at`: 2026-10-05 (maintained)
- README: "A library for property-based testing with dependent types and automatic derivation of generators for Idris 2". Status: "under heavy construction". "**For now, it lacks most of things required for normal property-based testing, like support for properties and fancy testing operations. Also, for now we do not support such important thing as shrinking. The current focus for now is on test data generators and automatic derivation of them.**"
- `deriveGen` produces `Gen`s. That is closer to writing the *generators* QuickSpec would need, not to discovering equations.

**control-spec** — unit tests; `spec-discover` finds test *files*, not equations.

- Repo: <https://github.com/dannypsnl/control-spec>
- Pack: `[db.control-spec]`, commit `1aa5c4b00d2409fabd9ac716a2f9afd570fa6968`
- GitHub `pushed_at`: 2025-01-10; description "unit test framework for idris2"
- README: `describe` / `it` / `shouldBe`. `spec-discover test/` "generate[s] all tests runner" from files named `*Spec.idr`. Discovery here means collecting unit-test modules, not inventing laws.

**async-spec** — async/IO unit tests.

- Pack: `[db.async-spec]`, url <https://github.com/stefan-hoeck/idris2-async>, `ipkg = async-spec/async-spec.ipkg`
- pack-db STATUS.md: "A testing framework for Async programs and IO in general"

**simple-tests** — tiny unit-test DSL.

- Repo: <https://gitlab.com/avidela/idris2-simple-tests>
- Pack: `[db.simple-tests]`, commit `945aab794e42d2d06c88433f9fd33c2c417e14d9`
- README: `runTests $ do` / `test "…" $ a \`shouldBe\` b`. Programmer writes expected values.

**tester** — another unit-test package.

- Repo: <https://github.com/hydrolarus/tester-idr>
- Pack: `[db.tester]`, commit `3dcdb54ed578a14597a17cb93c926734a9da69ca`
- README: "A testing framework for Idris 2." `test "it works" $ do assertEq (1 + 1) 2`. Requires Idris 2 ≥ 0.5.0.

**test** (compiler library) — `Test.Golden`, see section B. Shown by `pack query test`. Not a `[db.test]` GitHub entry in `nightly-260921.toml`; it ships with the compiler (`libs/test`).

**algebra** — *stated* algebraic laws as proof records, not discovered.

- Repo: <https://github.com/stefan-hoeck/idris2-algebra>
- Pack: `[db.algebra]`, has `test = test/test.ipkg`
- README: "This library provides laws and proofs for common algebraic structures". Example: `record Monoid (a : Type) (z : a) (p : Op2 a)` with fields `associative`, `rightNeutral`, `leftNeutral` whose types are equalities such as `{u : a} -> z \`p\` u === u`. The programmer (or library author) *supplies* the proof. This is strategy 5 (encode the law in a type), the opposite of QuickSpec (guess the law from tests).

**bounded-doubles-hedgehog-generators** / **evince-hedgehog** — Hedgehog `Gen`s for other libraries, not law discovery. Pack entries exist in `nightly-260921.toml`.

### Names that sound like discovery but are not

- `control-spec`'s `spec-discover`: file discovery for unit tests.
- Hedgehog README "No automatic detection of properties in source files (yet)": detecting *already-written* `Property` values in source, à la tasty/hspec discovery — still not generating equations from a signature.
- `idris2-prim` (<https://github.com/stefan-hoeck/idris2-prim>): axioms and derived corollaries for primitive types, stated by the library, not found by testing.

---

## D. Idris 1 leftovers

These are **Idris 1** unless a later port is shown. None appear in pack `nightly-260921`.

**specdris** (unit tests, Idris 1.0)

- Repo: <https://github.com/pheymann/specdris> (the live repo; not `pierrebeaucamp/specdris` — Pierre Beaucamp's GitHub has Idris DOM/WebGL libs, not specdris)
- GitHub: created 2017-07-05, `pushed_at` 2019-03-21, language Idris, not archived, description "A test framework for Idris"
- README: "With this framework you can write spec-like **Unit Tests** in Idris" (`describe` / `it` / `shouldBe`). "**This testing framework is written with `Idris 1.0`.**"
- Open issue #1 (2017-07-05): "Add QuickCheck integration" — still open; the README has no QuickCheck and no law discovery.
- Not in pack. Idris 1-only.

**david-christiansen/idris-quickcheck** (QuickCheck port, Idris 1)

- Repo: <https://github.com/david-christiansen/idris-quickcheck>
- README is one line: "A port of QuickCheck to Idris"
- `pushed_at`: 2017-10-30
- Source `QuickCheck.idr` uses Idris 1 syntax (`instance` not `implementation`, `%include C "time.h"`, `mkForeign`). Comment: "Direct port from the first QuickCheck paper." It defines `Arbitrary`, `Property`, `quickCheck` / `check'` — programmer-written properties, random tests. **Not** QuickSpec. **Not** Idris 2.

**Idris 1 contrib `Test.Unit`**

- Changelog of Idris 1 (`idris-lang/Idris-dev`): "Added `Test.Unit` to `contrib`" (<https://github.com/idris-lang/Idris-dev/blob/master/CHANGELOG.md>)
- Source: <https://raw.githubusercontent.com/idris-lang/Idris-dev/master/libs/contrib/Test/Unit.idr> — "A simple Unit testing framework", re-exporting `Test.Unit.Assertions` (`assertTrue`, `assertEquals`, …). Programmer writes the expected value. Idris 2 contrib no longer has this module (only `Test/REDIRECT.md`).

No Idris 1 QuickSpec port was found. Searched: GitHub repos with language Idris matching `quickspec` (`gh search repos "quickspec" --language=Idris`, empty); `gh search code "quickspec" --repo idris-lang/Idris2`, empty.

---

## E. This machine and this project

### Pack / Idris install

- `~/.pack` does **not** exist. Pack state is XDG: `~/.local/state/pack`, config `~/.config/pack/pack.toml`, cache `~/.cache/pack`.
- Binaries: `/home/jmsbpp/.local/bin/pack`, `/home/jmsbpp/.local/bin/idris2`
- Compiler libs under `/home/jmsbpp/.local/idris2-0.8.0` (prelude) and `/home/jmsbpp/.local/idris2-bootstrap/idris2-0.8.0/` (includes `test-0.8.0/Test/Golden.idr`)
- Installed pack libraries for commit `1c630e67…`: `base`, `collie`, `contrib`, `idris2`, `json-schema`, `linear`, `network`, `prelude`. No hedgehog, deptycheck, tester, or specdris.

### This worktree: `/home/jmsbpp/apps/typed-model-api/.worktrees/feat/json-schema-types-integration`

`pack.toml` custom packages: `json-schema` (github `madman-bob/idris2-json-schema` at commit `83a7214e8d28b2367c4f585a40acfb7edbbc0ce2`), local `typed-model-api`, `typed-model-api-test`, `typegen`, `typegen-test`.

| Test suite | Depends | What it actually does |
|------------|---------|------------------------|
| `test/test.ipkg` (`typed-model-api-test`) | `typed-model-api` only | `test/src/Main.idr` prints `"Test successful!"` |
| `typegen/test/test.ipkg` (`typegen-test`) | `typegen` only | Hand-rolled `assertEq` / `assertSuccess` / `assertFailure` over `runTypegen`; no Hedgehog, no Golden, no specdris |

Workspace grep for `hedgehog`, `quickcheck`, `specdris`, `leancheck`, `smallcheck`, `quickspec`, `Test.Golden`, `deptycheck`, `control-spec`: **no matches** (other than this research note).

Parent repo `/home/jmsbpp/apps/typed-model-api` likewise has a stub `test/test.ipkg` and no property-testing dependency.

### What json-schema generates (so "laws of generated types" has a concrete meaning)

Library README: <https://github.com/madman-bob/idris2-json-schema>. "Generate Idris 2 data types from a JSON Schema." Example: an object schema becomes `record Main` with fields.

Compiler (`JSONSchema/Compiler.idr` in the cached clone `~/.cache/pack/git/github.com/madman-bob/idris2-json-schema`):

- Object → `record` + constructor + fields (`Maybe` if not required)
- Enum → `data` with nullary constructors
- anyOf → `data` with one constructor per variant
- Optional `Cast T JSON` if `--json-casts` / `jsonCasts` is on (`writeCast`)

This worktree's typegen (`typegen/Typegen.idr`) sets `jsonCasts = False` and its tests assert generated source contains no `Cast`.

json-schema's own tests (`tests/json-schema-tests.ipkg`, `depends = contrib, test`, `JSONSchemaTests.idr`) use **`Test.Golden`** (`testsInDir` over Support/Primitive/Compose/Refs/CLI). They compare generated `.idr` text to `expected` files. Example `tests/Primitive/Object/expected`: a `record Address` and `record Main`. That is strategy Golden, applied to the *generator*, not law discovery on the *generated types*.

Generated artefacts are primarily types (records/ADTs) plus optional JSON casts. They are not a rich algebraic signature like `reverse`/`++`/`[]`. QuickSpec needs functions in a signature; field projections and constructors alone yield few interesting equations unless you add operations (JSON round-trip, `Eq`, schema-specific functions).

---

## F. Academic / first-party claims about spec discovery on Idris

Searched first-party Idris papers/docs/READMEs for spec discovery / automatic law finding:

- Idris 2 tutorial theorem-proving page: how to *prove* equalities, not how to *find* them.
- `idris2-algebra` README: how to *encode* laws as indexed records.
- `idris2-hedgehog` README/tutorial: how to *write* properties; list-reverse is "completely pointless" because it is provable.
- `deptycheck` README: generator derivation; properties not implemented.
- Idris2 `libs/papers`: no README at the URL `libs/papers/README.md` (404). No claim of QuickSpec found via repo search `gh search code "quickspec" --repo idris-lang/Idris2` (empty).
- Smallbone/Claessen QuickSpec papers: Haskell and Erlang; Hipster is Isabelle; HipSpec is Haskell. No Idris.

**Absence:** no first-party Idris paper or library README found that claims automatic equational-spec discovery comparable to QuickSpec.

---

## G. Practical answer for this project (JSON Schema → Idris types)

If the goal is QuickSpec-like **law discovery** for types generated from JSON Schema:

**What exists today**

1. Nothing that, given the generated module, prints equational laws.
2. Golden tests of *code generation* (json-schema upstream already does this with `Test.Golden`; this worktree's typegen tests do the same job with hand-rolled `assertEq` on files and process exit codes).
3. If you want *property* testing of generated types (round-trip, `Eq` congruence, constructor/field inverses), the maintained Idris 2 tool is **hedgehog** (`pack install hedgehog`). You would write `Property` values yourself (`forAll genRecord $ \x => …`) and, unless you use SOP generic gens, write `Gen`s yourself. DepTyCheck can derive generators for many ADTs but currently does not provide the property runner or shrinking.
4. If a law is actually true of total Idris functions on inductive types, the Idris-native move is to **prove** it (`x = y` + `total`), as the official theorem-proving tutorial and Hedgehog's own intro both describe. `idris2-algebra` shows how to bundle such proofs.
5. Optional JSON `Cast` (disabled in this worktree) is the only generated "operation" beyond constructors/fields. A round-trip law would still have to be *stated* (Hedgehog) or *proved* (if `Cast` is total and invertible on the schema's image). Nothing will invent `cast (cast x) = x` for you.

**What you would have to write by hand**

- A QuickSpec clone in Idris 2: term generation up to a size bound, partitioning by equality tests, pruning (QuickSpec 2 uses Twee). No such library is in pack or the Idris2 repo. That is a research-scale tool, not a missing import.
- Or: export generated functions to Haskell and run Hackage QuickSpec there. That is a foreign toolchain, not Idris 2 support.
- Or: write the candidate laws yourself and check them with Hedgehog / prove them.

**What proving gives you that QuickSpec does not**

QuickSpec's TAP 2010 paper is explicit: testing-based discovery is *potentially unsound*. A total Idris proof of `f (g x) = x` is checked by the kernel. For generated schema types, many "laws" are either definitional (`MkT a b` projections) or would follow from a verified JSON codec; the missing piece is the codec/invariants, not a law finder.

---

## Package table (concise)

| Package | URL | Idris | In pack `nightly-260921`? | Status | Strategy |
|---------|-----|-------|---------------------------|--------|----------|
| quickspec (Haskell) | https://hackage.haskell.org/package/quickspec · https://github.com/nick8325/quickspec | Haskell | n/a | maintained (2.2.2, 2026-08-27) | 1 law discovery |
| hedgehog | https://github.com/stefan-hoeck/idris2-hedgehog | **2** | **yes** | maintained (push 2026-07-05) | 4 Hedgehog PBT |
| deptycheck | https://github.com/buzden/deptycheck | **2** | **yes** | maintained, incomplete PBT (push 2026-10-05) | generators only |
| test / Test.Golden | https://github.com/idris-lang/Idris2/tree/main/libs/test | **2** | ships with compiler | maintained | golden files |
| replica | https://github.com/ReplicaTest/REPLica | **2** | **no** (wiki only) | maintained independently | golden CLI |
| control-spec | https://github.com/dannypsnl/control-spec | **2** | **yes** | last push 2025-01-10 | unit tests (+ file discovery) |
| async-spec | https://github.com/stefan-hoeck/idris2-async | **2** | **yes** | in async repo | async unit tests |
| simple-tests | https://gitlab.com/avidela/idris2-simple-tests | **2** | **yes** | in pack | unit tests |
| tester | https://github.com/hydrolarus/tester-idr | **2** | **yes** | in pack | unit tests |
| algebra | https://github.com/stefan-hoeck/idris2-algebra | **2** | **yes** | in pack | 5 proof-carrying laws |
| specdris | https://github.com/pheymann/specdris | **1 only** (README: Idris 1.0) | **no** | last push 2019-03-21 | unit tests |
| idris-quickcheck | https://github.com/david-christiansen/idris-quickcheck | **1 only** (`instance`, `%include C`) | **no** | last push 2017-10-30 | 2 QuickCheck |
| Test.Unit | https://github.com/idris-lang/Idris-dev `libs/contrib/Test/Unit.idr` | **1 only** | **no** (removed in Idris 2 contrib) | Idris 1 contrib | unit tests |

---

## Absences (searched, not found)

Named so a later reader does not have to re-search:

- Pack queries with empty result: `quickspec`, `quickcheck`, `specdris`, `tasty`, `leancheck`, `smallcheck`, `unit-test`, `property`, `law`, `replica`
- `collections/HEAD.toml` and `nightly-260921.toml`: no `quickspec` / `quickcheck` / `leancheck` / `smallcheck` / `specdris` / `replica` entries
- `gh search repos "quickspec" --language=Idris`: no hits
- `gh search code "quickspec" --repo idris-lang/Idris2`: no hits
- Idris 2 contrib `Test/`: only `REDIRECT.md`
- Idris 2 `libs/test`: only `Test.Golden`
- idris2.readthedocs.io: no property-testing or QuickSpec page
- Idris2 wiki Testing section: hedgehog + replica only
- This worktree and parent repo: no testing-library dependency beyond hand-rolled asserts / a stub main
- No Idris 1 QuickSpec port found; specdris's QuickCheck issue was never completed
- No SmallCheck/LeanCheck Idris port found in pack or the wiki

---

## Source index

| Claim | Source |
|-------|--------|
| QuickSpec discovers equations from a signature via QuickCheck | Hackage <https://hackage.haskell.org/package/quickspec>; GitHub README; Haddock `QuickSpec` |
| QuickSpec ≠ writing properties | TAP 2010 PDF §1; JFP 2017 abstract and §1 |
| Idris 2 in-tree tests are Golden only | `libs/test/README.md`, `libs/test/test.ipkg`, `contrib/Test/REDIRECT.md` |
| No in-tree unit/property framework (historical) | Idris2 `CONTRIBUTING.md` at `d9cc448` |
| Community PBT is Hedgehog | Idris2 wiki Third-party Libraries; hedgehog README |
| Hedgehog does not discover properties | hedgehog README limitations; `forAll`/`property` in `Hedgehog.Internal.Property` |
| DepTyCheck lacks properties | deptycheck README Status |
| specdris / idris-quickcheck are Idris 1 | their READMEs and source syntax; pack misses |
| This project tests by asserts/golden-style, not PBT | `test/src/Main.idr`, `typegen/test/src/Main.idr`, `*.ipkg` |
| json-schema tests are Golden | `tests/JSONSchemaTests.idr` `import Test.Golden` |
| Proofs are the Idris-native law mechanism | idris2.readthedocs theorem-proving tutorial; hedgehog Intro.md |
