# REF

- TypeScript Handbook, Utility Types (`NonNullable`, `Exclude`): https://www.typescriptlang.org/docs/handbook/utility-types.html#nonnullabletype
- TypeScript Handbook source (examples): https://github.com/microsoft/TypeScript-Website/blob/v2/packages/documentation/copy/en/reference/Utility%20Types.md
- TypeScript lib definition (current): https://github.com/microsoft/TypeScript/blob/main/src/lib/es5.d.ts (`type NonNullable<T> = T & {}`)
- TypeScript 4.8 release notes (`NonNullable` rewritten to `T & {}`): https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-8.html
- TypeScript 2.8 release notes (original distributive `NonNullable` / `Exclude`): https://www.typescriptlang.org/docs/handbook/release-notes/typescript-2-8.html
- TypeScript Handbook, `null` and `undefined` / `strictNullChecks`: https://www.typescriptlang.org/docs/handbook/2/everyday-types.html#null-and-undefined
- TypeScript Handbook, optional properties: https://www.typescriptlang.org/docs/handbook/2/everyday-types.html (Optional Properties); https://www.typescriptlang.org/docs/handbook/2/objects.html#optional-properties
- TypeScript Handbook, intersection types: https://www.typescriptlang.org/docs/handbook/2/objects.html#intersection-types
- TypeScript Handbook, distributive conditional types: https://www.typescriptlang.org/docs/handbook/2/conditional-types.html#distributive-conditional-types
- TypeScript Handbook, erased types: https://www.typescriptlang.org/docs/handbook/typescript-from-scratch.html (Erased Types); https://www.typescriptlang.org/docs/handbook/2/basic-types.html (Erased Types)
- Installed TypeSafe JS SDK v0.7.0 declarations: `node_modules/@typesafe-ai/sdk/dist/index.d.mts` (same types in `index.d.cts`)
- TypeSafe JS SDK docs: https://docs.typesafe.ai/go/js-sdk.md
- TypeSafe OpenAPI 3.1: https://api.typesafe.ai/openapi.json (`components.schemas.SystemOneRequest`)
- Idris 2 Prelude `Maybe`, `Dec`: https://github.com/idris-lang/Idris2/blob/main/libs/prelude/Prelude/Types.idr
- Idris 2 Prelude `Not`: https://github.com/idris-lang/Idris2/blob/main/libs/prelude/Prelude/Basics.idr
- Idris 2 Builtin `Void`: https://github.com/idris-lang/Idris2/blob/main/libs/prelude/Builtin.idr
- Idris 2 `IsJust` / `fromJust` / `isItJust`: https://github.com/idris-lang/Idris2/blob/main/libs/base/Data/Maybe.idr
- Idris 2 `IsLeft` / `IsRight` (same view pattern): https://github.com/idris-lang/Idris2/blob/main/libs/base/Data/Either.idr
- Idris 2 `NonEmpty` (list emptiness): https://github.com/idris-lang/Idris2/blob/main/libs/base/Data/List.idr
- Idris 2 `List1` (non-empty list datatype): https://github.com/idris-lang/Idris2/blob/main/libs/base/Data/List1.idr
- Idris 2 `Subset` / `Exists`: https://github.com/idris-lang/Idris2/blob/main/libs/base/Data/DPair.idr
- Idris 2 `So`: https://github.com/idris-lang/Idris2/blob/main/libs/base/Data/So.idr
- Idris 2 JS FFI pointer-null check (runtime, not a type transformer): https://github.com/idris-lang/Idris2/blob/main/libs/prelude/PrimIO.idr

# MAIN

**Short answer:** `NonNullable<T>` is a TypeScript type transformer whose inhabitants are the inhabitants of `T` that are not `null` or `undefined`. Current lib definition is `T & {}` (TypeScript 4.8+); the handbook still describes it as excluding `null` and `undefined`. It is compile-time only: JS still has `null`. Applied to this SDK's `EntryType`, it is the same union with the top-level `null` member removed (`undefined` was never a member). Nested `null`s inside objects/arrays remain, because `NonNullable` is not recursive. Idris 2 has no `null`/`undefined` and no `Exclude`/`NonNullable` operator; optionality is `Maybe a`, so the equivalent of `NonNullable<Maybe a>` is just `a`, and the equivalent of `NonNullable<EntryType>` is a sum **without** a `Null` constructor (or `State` rather than `Maybe State`). Idris `NonEmpty` is list non-emptiness and is not this.

# 1. General semantics of `NonNullable<T>`

## What the handbook says it excludes

The Utility Types handbook (released with TypeScript 2.8) states:

> Constructs a type by excluding `null` and `undefined` from `Type`.

and gives:

```ts
type T0 = NonNullable<string | number | undefined>;
type T1 = NonNullable<string[] | null | undefined>;
```

which (as annotated in the TypeScript 2.8 notes) reduce to `string | number` and `string[]` respectively. So it removes **both** `null` and `undefined`, and it does so **memberwise on a union**: a union of several types plus `null`/`undefined` becomes the union of the remaining members.

`Exclude<UnionType, ExcludedMembers>` is the more general operator: “excluding from `UnionType` all union members that are assignable to `ExcludedMembers`.” The original `NonNullable` was that operator specialised to `null | undefined` (see below).

## Current lib definition: `T & {}`

In `src/lib/es5.d.ts` on TypeScript `main` (verified 2026-10-24):

```ts
/**
 * Exclude null and undefined from T
 */
type NonNullable<T> = T & {};
```

(`Exclude` remains the distributive conditional `T extends U ? never : T` in the same file.)

TypeScript 4.8 documents the rewrite, under `--strictNullChecks`:

```diff
- type NonNullable<T> = T extends null | undefined ? never : T;
+ type NonNullable<T> = T & {};
```

Reason given: `{}` intersected with any other object type simplifies to that object type, and `{} & null` / `{} & undefined` “just get tossed away.” Intersections reduce and assign more readily than conditional types, so e.g. `NonNullable<NonNullable<T>>` simplifies. Narrowing `value === undefined || value === null` now produces `T & {}`, which is identical to `NonNullable<T>`.

The empty object type `{}` here is “any non-nullish value”: the same 4.8 notes say `unknown` is close in spirit to `{} | null | undefined` because that union “accepts `null`, `undefined`, and any other type.” Intersecting `T` with `{}` therefore keeps those members of `T` that inhabit `{}` and drops `null`/`undefined`.

Intersection syntax itself is `&` (Handbook, Intersection Types). The 4.8 notes are the first-party source for what `T & {}` does to `null`/`undefined`; the objects-handbook page only shows `&` combining object types.

**`strictNullChecks`:** how `null`/`undefined` interact with other types depends on this flag (Everyday Types). The 4.8 intersection/`NonNullable` changes are specified under `--strictNullChecks`. This note assumes that flag (the SDK’s published `.d.ts` is written against modern TS with null as a distinct union member).

## Older definition, and distributivity over unions

TypeScript 2.8 introduced `NonNullable` as a **distributive conditional type**:

```ts
type Diff<T, U> = T extends U ? never : T;
type NonNullable<T> = Diff<T, null | undefined>; // Remove null and undefined from T
```

and shipped it in `lib.d.ts` as “Exclude `null` and `undefined` from `T`.”

A conditional `T extends U ? X : Y` whose checked type is a **naked type parameter** is distributive: instantiating with `A | B | C` resolves as `(A extends U ? X : Y) | (B extends U ? X : Y) | (C extends U ? X : Y)` (TS 2.8 notes; Handbook, Distributive Conditional Types). That is why `NonNullable<string | number | undefined>` is `string | number` rather than a single residual blob: `undefined extends null | undefined` becomes `never`, and `never` disappears from the union.

The current `T & {}` encoding is **not** a conditional type. It still filters unions in the documented examples (`string | number | undefined` → `string | number`; `string[] | null | undefined` → `string[]`) because `null & {}` and `undefined & {}` reduce to `never` (TS 4.8). It does **not** recurse into structure: `NonNullable<string[] | null>` is `string[]`, not an array of `NonNullable<string>` (handbook `T1` example). A mapped/conditional walk over properties would be a different type; `NonNullable` is not that.

## Compile-time erasure

TypeScript types are erased. After checking, “the resulting plain JS code has no type information”; “the type system itself has no bearing on how your program works when it runs” (Handbook, TypeScript for the New Programmer, Erased Types). Type annotations “never change the runtime behavior of your program” (Handbook, The Basics, Erased Types). The postfix `!` non-null assertion “doesn’t change the runtime behavior of your code” (Everyday Types).

So `NonNullable<T>` does not insert a runtime check. JavaScript still has the values `null` and `undefined` (Everyday Types: “two primitive values used to signal absent or uninitialized value”). A value typed `NonNullable<EntryType>` can still be `null` at runtime if it was asserted, unsoundly constructed, or came from untyped JS. Any actual rejection of `null` is extra runtime logic (the SDK does add that for `state`; see §2).

# 2. `NonNullable<EntryType>` in the TypeSafe JS SDK (v0.7.0)

Source: installed `@typesafe-ai/sdk` `dist/index.d.mts` / `index.d.cts` (`VERSION = "0.7.0"`). The two declaration files match on these types.

## The unions

```ts
type JsonValue =
  | string | number | boolean | null
  | JsonValue[]
  | { [key: string]: JsonValue };

type ContentValue =
  | string | number | boolean | null
  | Asset | TextWithAssets
  | ContentValue[]
  | { [key: string]: ContentValue };

type EntryType =
  | string
  | Asset
  | TextWithAssets
  | { [key: string]: ContentValue }
  | ContentValue[]
  | null;
```

`EntryType`’s own comment: “Text, an asset, a JSON object or array, or `null` for instructions and criteria.” It does **not** include top-level `number` or `boolean` (those live in `ContentValue` / `JsonValue`). It does **not** include `undefined`.

## Set difference

`NonNullable<EntryType>` = `EntryType` without the `null` member, and without `undefined` (which was not a member):

```
string | Asset | TextWithAssets | { [key: string]: ContentValue } | ContentValue[]
```

That is the type of `SystemOneRequest.state`:

```ts
interface SystemOneRequest<Q extends Questions = Questions> {
  /** Text, an asset, a JSON object, or an array to evaluate. */
  state: NonNullable<EntryType>;
  questions: Q;
  model?: string;
  assets?: Record<string, Asset>;
}
```

The comment on `state` lists text / asset / object / array — not `null`. `state` is a required property (no `?`).

## Nested `null` is not stripped

`ContentValue` includes `null`. Object and array members of `EntryType` are `{ [key: string]: ContentValue }` and `ContentValue[]`. `NonNullable` only intersects the **top-level** union with `{}`; it does not map over keys or array elements (lib definition `T & {}`; handbook examples are top-level union filters). Therefore:

| Value | In `EntryType`? | In `NonNullable<EntryType>`? |
| --- | --- | --- |
| `null` | yes (`null` member) | **no** |
| `undefined` | no | no |
| `"text"` / `Image` / `TextWithAssets` | yes | yes |
| `{ foo: null }` | yes (object of `ContentValue`) | **yes** |
| `[null]` | yes (`ContentValue[]`) | **yes** |
| `{ nested: { x: null } }` | yes | **yes** |

`state: { foo: null }` is allowed by the type; `state: null` is not.

## Contrast: `instructions?: EntryType`

Question types use optional `instructions` with the **full** `EntryType`, e.g. `NoulQuestion`:

```ts
instructions?: EntryType;
```

`?` means the property may be omitted; reading a missing optional property yields `undefined` (Everyday Types, Optional Properties; Objects handbook: optionality means “if the property is set, it better have a specific type”). `EntryType` already includes `null`. So for instructions, **omission and `null` are both allowed**. `noul` encodes the “must actually describe something” rule with overloads:

```ts
declare const noul: {
  (instructions: NonNullable<EntryType>, criteria?: NoulQuestion["criteria"]): NoulQuestion;
  (instructions: EntryType | undefined, criteria: {
    true: NonNullable<EntryType>;
    false?: EntryType;
  } | {
    true?: EntryType;
    false: NonNullable<EntryType>;
  }): NoulQuestion;
};
```

First overload: instructions are a present, non-null entry. Second: instructions may be `EntryType | undefined` (null or omitted) **if** at least one of `criteria.true` / `criteria.false` is `NonNullable<EntryType>`. That matches `NoulQuestion`’s comment: “at least one is required when `instructions` is omitted or `null`.”

## OpenAPI / HTTP schema (state cannot be JSON `null`)

`POST /v1/systemone` body is `SystemOneRequest`. `state` is **required** (together with `model` and `questions`) and is:

```json
"anyOf": [
  { "type": "string" },
  { "additionalProperties": true, "type": "object" },
  { "items": {}, "type": "array" }
]
```

There is no `"type": "null"` branch. Nested JSON `null` is still possible: object `additionalProperties: true` and array `items: {}` accept arbitrary JSON, including `null` values. Question `instructions` **do** include `"type": "null"` in their `anyOf`.

The SDK’s client-side union is wider than the JSON schema at the top level: `Asset` and `TextWithAssets` are classes that serialize to strings (their `toJSON()`). OpenAPI `state` is the wire shape (string | object | array), not those classes.

SDK `systemOne` JSDoc also records a **runtime** check: `@throws {TypeSafeError} State is \`null\` or omitted, ...`. Types erase; this throw is the runtime counterpart.

## JS SDK docs / README

https://docs.typesafe.ai/go/js-sdk.md and the installed `README.md` show `state` as a string, object, image, or `withAssets` text. They do **not** say in prose “state cannot be null.” The non-null rule is in the `.d.ts` (`NonNullable<EntryType>`), the OpenAPI schema (no `null` branch, required), and the `systemOne` `@throws` text. This note does not invent a further API rule.

# 3. Idris 2 equivalents

Idris 2 has no JS `null` / `undefined` in Prelude types. Absence is an explicit constructor of a sum, most often `Maybe`:

```idris
data Maybe : (ty : Type) -> Type where
  Nothing : Maybe ty
  Just : (x : ty) -> Maybe ty
```

(`Prelude.Types`; comment: “An optional value.”) `Nothing = Just x` is `Uninhabited`.

`Not t = t -> Void` (`Prelude.Basics`). `Void` is the empty type, no constructors (`Builtin`).

There is **no** Prelude/base operator that strikes a constructor out of a union the way TS `Exclude` / `NonNullable` do. Idris does not have untagged unions `A | B`; a datatype is an inductive sum whose constructors are fixed at definition. Consulted: `Prelude.Basics`, `Prelude.Types`, `Data.Maybe`, `Data.Either`, `Data.List`, `Data.List1`, `Data.DPair`, `Data.So`. None defines `NonNullable` or `Exclude`. (contrib was not exhaustively searched; nothing in those base files is a union-member eraser.)

The JS FFI **does** observe host `null`/`undefined` at the pointer boundary: `prim__nullAnyPtr` is implemented as `x===undefined||x===null?1:0` (`PrimIO.idr`). That is a runtime check on `AnyPtr`, not a type transformer on Idris values.

## Closest encodings

**1. Don’t put the null constructor in the type used at the call site (idiomatic).**

If optional content is `Maybe State`, required state is `State`. That is the equivalent of `NonNullable<Maybe a> ≡ a`. If a single datatype includes a `Null` constructor for instructions/criteria, define a second datatype without it for `state` (TS did this with a type alias over a union; Idris does it by actually omitting the constructor).

This matches how the SDK already splits comments: `EntryType` “or `null` for instructions and criteria” vs `state: NonNullable<EntryType>`.

**2. A predicate / view on a value that might still be the full sum.**

If you must keep one datatype that includes `Null`:

- `Not (x = Null)` — a function `x = Null -> Void` (`Not` in `Prelude.Basics`).
- A view, as `Data.Maybe` does for `Nothing`/`Just`:

```idris
data IsJust : Maybe a -> Type where
  ItIsJust : IsJust (Just x)

fromJust : (v : Maybe a) -> (0 _ : IsJust v) => a
isItJust : (v : Maybe a) -> Dec (IsJust v)
```

`IsJust Nothing` is `Uninhabited`. `Dec` is `Yes prf | No contra` (`Prelude.Types`: “A decidable property either holds or is a contradiction”). `Data.Either` has the same pattern (`IsLeft` / `IsRight`). `DecEq` (`decEq : (x1 : t) -> (x2 : t) -> Dec (x1 = x2)`) is only needed if you decide `x = Null` by equality rather than by a dedicated view; `isItJust` does not use `DecEq`.

**3. Subset type (erased proof, value kept).**

`Data.DPair.Subset`:

```idris
record Subset type pred where
  constructor Element
  fst : type
  0 snd : pred fst
```

Comment: “extrinsic invariants about a value … erased at runtime but used at compile time.” `Subset Entry (\x => Not (x = Null))` (or `Subset (Maybe a) IsJust`) is a dependent pair of a value plus a zero-quantity proof — closer to a refinement of `EntryType` than to TS `NonNullable`, which never carries a proof term.

`So : Bool -> Type` with `Oh : So True` (`Data.So`) lifts a Boolean test (`So (isJust x)`). The module itself says if you are not on primitives, “define a type of evidence for the property” instead — i.e. prefer `IsJust` over `So`.

`Exists` in the same file **erases the witness and keeps the payload** — the opposite quantity split from `Subset`. Not an analogue of `NonNullable`.

A type-level function `dropNull : Entry -> Type` that maps the `Null` constructor to `Void` and other constructors to themselves can be written by hand; it is not in the library, and it is not how Idris APIs normally exclude a case.

## Name collision: `NonEmpty` ≠ `NonNullable`

`Data.List.NonEmpty` is a **predicate on lists**:

```idris
data NonEmpty : (xs : List a) -> Type where
  IsNonEmpty : NonEmpty (x :: xs)
```

`Uninhabited (NonEmpty [])`. It proves a list is not `Nil`; it has nothing to do with `null`. `Data.List1` is the corresponding datatype that never had an empty constructor (`head : a`, `tail : List a`). Those are the Idris analogue of “omit the empty case,” not of TS `NonNullable`.

## How the encodings differ from TypeScript

| | TypeScript `NonNullable<T>` | Idris |
| --- | --- | --- |
| What is dropped | union members `null` and `undefined` | a constructor you choose not to include, or a proof it is not that constructor |
| Mechanism | type alias `T & {}` (erasable) | a different datatype, or `IsJust` / `Not (x = Null)` / `Subset` |
| `null` at runtime | still exists in JS | not an Idris value; JS null only at FFI pointers |
| Nested nulls | not stripped | whatever nested type you wrote (`Maybe` inside a record stays `Maybe`) |
| Optional field | `p?: T` adds `undefined`; `T` may still include `null` | `Maybe a` is explicit; required field is `a` |
| Proof term | none | views/`Subset` carry (possibly erased) proofs |

For this client: type `systemOne` **state** as the Idris sum that corresponds to `string | Asset | TextWithAssets | object | array` — **not** `Maybe` of that sum, and **not** a sum that still has a `Null` case. Keep `null` (as `Nothing` or a `Null` constructor) on instructions/criteria, including nested `ContentValue`. That is `NonNullable<EntryType>`: top-level null struck, nested nulls left alone.
