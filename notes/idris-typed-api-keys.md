# REF

- Pack catalog: https://github.com/stefan-hoeck/idris2-pack-db/blob/main/STATUS.md
- Pack HEAD collection: https://github.com/stefan-hoeck/idris2-pack-db/blob/main/collections/HEAD.toml
- Idris 2 wiki third-party list: https://github.com/idris-lang/Idris2/wiki/Third-party-Libraries
- Idris 2 modules / export visibility: https://idris2.readthedocs.io/en/latest/tutorial/modules.html
- Idris 2 `System.getEnv`: https://github.com/idris-lang/Idris2/blob/main/libs/base/System.idr
- Idris 2 `Prelude.Show`: https://github.com/idris-lang/Idris2/blob/main/libs/prelude/Prelude/Show.idr
- Idris 2 `print` / `printLn`: https://github.com/idris-lang/Idris2/blob/main/libs/prelude/Prelude/IO.idr
- Idris 2 `base.ipkg`: https://github.com/idris-lang/Idris2/blob/main/libs/base/base.ipkg
- Idris 2 `contrib.ipkg`: https://github.com/idris-lang/Idris2/blob/main/libs/contrib/contrib.ipkg
- Idris 2 `prelude.ipkg`: https://github.com/idris-lang/Idris2/blob/main/libs/prelude/prelude.ipkg
- HTTP Authorization (Bearer as `String`): https://github.com/idris-community/idris2-http/blob/master/src/Network/HTTP/Authorization.idr
- HTTP Header `AuthorizationScheme`: https://github.com/idris-community/idris2-http/blob/master/src/Network/HTTP/Header.idr
- HTTP client `request` headers: https://github.com/idris-community/idris2-http/blob/master/src/Network/HTTP/Client.idr
- HTTP message `Show` (headers included): https://github.com/idris-community/idris2-http/blob/master/src/Network/HTTP/Message.idr
- HTTP URL credentials `Show`: https://github.com/idris-community/idris2-http/blob/master/src/Network/HTTP/URL.idr
- JSON `ToJSON`: https://github.com/stefan-hoeck/idris2-json/blob/main/src/JSON/ToJSON.idr
- Refinement types: https://github.com/stefan-hoeck/idris2-refined
- Passphrase hashing (not API keys): https://github.com/stefan-hoeck/idris2-crypt
- bcrypt hashing (not API keys): https://github.com/Matthew-Mosior/idris2-bcrypt
- TypeSafe intro: https://docs.typesafe.ai/introduction
- TypeSafe HTTP API (Bearer): https://docs.typesafe.ai/go/api.md
- TypeSafe quickstart (`TYPESAFE_API_KEY`): https://docs.typesafe.ai/introduction/quickstart.md
- TypeSafe Python SDK env names: https://docs.typesafe.ai/sdk/python/api/constants.md
- TypeSafe Python SDK log redaction: https://docs.typesafe.ai/sdk/python/usage/advanced.md
- OpenRouter authentication: https://openrouter.ai/docs/api/reference/authentication

# MAIN

**Short answer:** Idris 2 has **no** library for secret / API-key types. pack-db HEAD.toml has no `secret`, `secrets`, `credential`, `api-key`, `token`, `password` (as a wrapper), `redaction`, `env`, or `dotenv` package. The compiler's `prelude` / `base` / `contrib` have no `Secret` type; env lookup is `System.getEnv : HasIO io => String -> io (Maybe String)` (not `getenv`). `idris2-http` takes Bearer tokens as bare `String` and **will** print them if you `show` headers/messages. Closest catalog pieces are `refined` (non-empty / ASCII predicates — **not** redaction) and `crypt`/`bcrypt` (passphrase **hashing**, not Bearer tokens).

For this project: do **not** add a pack dep for secrets. Hand-write an opaque `export data OpenRouterKey` (constructors private), custom `Show` that redacts, **no** `ToJSON` instance, load with `getEnv "OPENROUTER_API_KEY"`, and only unwrap inside a `bearerHeader` that calls `applyBearerAuth`.

# PACK-DB: what exists

Searched `collections/HEAD.toml` and `STATUS.md` for `secret`, `secrets`, `credential`, `api-key`, `token`, `password`, `redaction`, `env`, `dotenv`, `config`, `refinement`, `refined`, `refined-types`, `refinedt`, `refinedv`, `refined-idris`, `newtype`, `opaque`. Hits below. **No `secret`, `secrets`, `credential`, `api-key`, `dotenv`, `env`, `redaction`, or `opaque` package names appear in HEAD.toml.** The only `token` hit is `ilex-core` ("token bounds and parse errors" — lexer tokens, not API tokens). `newtype-deriving` exists on GitHub but is **commented out** of HEAD.toml.

## In pack-db (canonical catalog)

| Pack name | Repo | STATUS.md description | Secret / key safety? |
| --- | --- | --- | --- |
| `refined` | https://github.com/stefan-hoeck/idris2-refined | "Refinement types in Idris2" | Predicates on values (length, trimmed, ASCII). README derives **`Show`** for refined strings, which **prints the value**. Not a secret type. |
| `refined-json` | same repo, `json/` | "Deriving JSON marshallers for refinement types" | **Serializes** the refined value. Opposite of redaction. STATUS.md: **failure**. |
| `refined-tsv` | same repo, `tsv/` | "Deriving TSV marshallers for refinement types" | Same: marshalling, not hiding. STATUS.md: **failure**. |
| `literal` | https://github.com/stefan-hoeck/idris2-literal | "Derivable interfaces for refined literals" | Compile-time literals, not secrets. |
| `crypt` | https://github.com/stefan-hoeck/idris2-crypt | "FFI bindings to the crypt C-library used for passphrase hashing" | One-way **hash** a passphrase (`cryptMaybe`, `cryptcheck`). Not Bearer wrapping. |
| `bcrypt` | https://github.com/Matthew-Mosior/idris2-bcrypt | "Idris2 bindings to the bcrypt password hashing algorithm" | Same: hashing, not API-key types. |
| `hmac` / `hash` / `sha` / `blake2b` / `scram` | janus repos | HMAC / SHA / SCRAM crypto | Message authentication / password-auth protocol. No `Secret` wrapper, no log redaction. |
| `json` / `json-simple` | https://github.com/stefan-hoeck/idris2-json | derivable JSON marshallers | `ToJSON String` encodes the string as JSON. No secret instance. |
| `ilex-toml` / `parser-toml` / `toml` | various | TOML **config file language** parsers | Parse config files; no secret redaction. |
| `collie` / `getopts` | ohad/collie, Idris2 contrib GetOpt | CLI argument parsing | Args, not env secrets. |
| `log4types` / `log4types-core` | https://github.com/bio-aeon/log4types | "composable logging, refined by dependent types" | Typed logging algebra. STATUS.md does not mention secret redaction. |

HEAD.toml entries (install names):

```toml
[db.refined]
type   = "github"
url    = "https://github.com/stefan-hoeck/idris2-refined"
commit = "main"
ipkg   = "refined.ipkg"

[db.refined-json]
type   = "github"
url    = "https://github.com/stefan-hoeck/idris2-refined"
commit = "main"
ipkg   = "json/refined-json.ipkg"

[db.crypt]
type   = "github"
url    = "https://github.com/stefan-hoeck/idris2-crypt"
commit = "main"
ipkg   = "crypt.ipkg"
```

Sources: https://github.com/stefan-hoeck/idris2-pack-db/blob/main/collections/HEAD.toml and https://github.com/stefan-hoeck/idris2-pack-db/blob/main/STATUS.md

Commented out (not in the catalog):

```toml
# [db.newtype-deriving]
# type   = "github"
# url    = "https://github.com/MarcelineVQ/idris2-newtype-deriving"
# commit = "master"
# ipkg   = "newtype-deriving.ipkg"
```

Source: https://github.com/stefan-hoeck/idris2-pack-db/blob/main/collections/HEAD.toml

## Not in pack-db / wiki

Wiki third-party list has no Secret / credentials / dotenv / env-config section. Network = TLS only; Data = json, dhall, xml, etc. Source: https://github.com/idris-lang/Idris2/wiki/Third-party-Libraries

There is no Idris 2 analogue of a "secret type that cannot be `Show`n / `ToJSON`d" in the catalog. Absence is from searching HEAD.toml package keys and STATUS.md descriptions, plus wiki.

# IDRIS 2 ITSELF: getenv, Show, no Secret

Compiler libraries under `libs/`: `prelude`, `base`, `contrib`, `linear`, `network`, `papers`, `test`. Source: https://github.com/idris-lang/Idris2/tree/main/libs

`prelude.ipkg` modules: `Builtin`, `PrimIO`, `Prelude`, `Prelude.Show`, `Prelude.IO`, … — no Secret. Source: https://github.com/idris-lang/Idris2/blob/main/libs/prelude/prelude.ipkg

`base.ipkg` includes `System`, `Data.String`, `Debug.Trace`, `Deriving.Show`. No Secret / Credential / Env module beyond `System`. Source: https://github.com/idris-lang/Idris2/blob/main/libs/base/base.ipkg

`contrib.ipkg` includes `Language.JSON`, `System.Console.GetOpt`, `Control.Validation`. No Secret. Source: https://github.com/idris-lang/Idris2/blob/main/libs/contrib/contrib.ipkg

## `getEnv` (not `getenv`) returns `Maybe String`

The identifier is **`getEnv`**. It is documented as returning `Nothing` when the variable is unset:

```idris
||| Retrieve the specified environment variable's value string, or `Nothing` if
||| there is no such environment variable.
|||
||| @ var the name of the environment variable to look up
export
getEnv : HasIO io => (var : String) -> io (Maybe String)
getEnv var
  = do env <- primIO $ prim__getEnv var
       if prim__nullPtr env /= 0
          then pure Nothing
          else pure (Just (prim__getString env))
```

FFI is libc `getenv` / Node `process.env[n]`. Also: `getEnvironment : io (List (String, String))`, `setEnv`, `unsetEnv`. Source: https://github.com/idris-lang/Idris2/blob/main/libs/base/System.idr

There is **no** dotenv loader in `base`/`contrib`. Loading a `.env` file would be a custom `System.File` parse, or the OS environment before process start.

## `Show` / `printLn` leak `String`s

`Show String` quotes the full contents:

```idris
export
Show String where
  show cs = strCons '"' (showLitString (unpack cs) "\"")
```

`Show (a, b)` concatenates both sides. `Show (Maybe a)` prints `Just x` via `showArg`. Source: https://github.com/idris-lang/Idris2/blob/main/libs/prelude/Prelude/Show.idr

`print` / `printLn` are `putStr . show` / `putStrLn . show`. Any `Show` instance that includes the key will hit stdout. Source: https://github.com/idris-lang/Idris2/blob/main/libs/prelude/Prelude/IO.idr

`Data.String.null : String -> Bool` is `(== "")` — usable as a runtime empty check, not a type. Source: https://github.com/idris-lang/Idris2/blob/main/libs/base/Data/String.idr

## Hiding constructors (the language feature that *is* the secret wrapper)

Idris 2 visibility for data types:

- `export` — type constructor exported; **data constructors are not**
- `public export` — type constructor **and** data constructors exported

Default is `private`. Source: https://idris2.readthedocs.io/en/latest/tutorial/modules.html

So an `export data OpenRouterKey` with an unexported constructor is opaque outside its module: callers cannot pattern-match the `String` out, cannot derive `Show`/`ToJSON` that inspects it, and can only use functions you export (`fromEnv`, `bearerHeader`).

# HOW TYPING / SAFETY WORKS IN EACH LIBRARY

## 1. `idris2-http`: Bearer is a `String`; `Show` prints it

`applyBearerAuth` is untyped besides `String`:

```idris
private
buildBearerAuth : String -- token
               -> (String, String)
buildBearerAuth token =
  ("Authorization", "Bearer " ++ token)

public export
applyBearerAuth : String -- token
               -> (String, String)
applyBearerAuth bearertoken =
  buildBearerAuth bearertoken
```

Source: https://github.com/idris-community/idris2-http/blob/master/src/Network/HTTP/Authorization.idr

The client `request` API takes `List (String, String)` headers. Source: https://github.com/idris-community/idris2-http/blob/master/src/Network/HTTP/Client.idr

Typed header lookup exists, and **stores the token as `String`**, with derived `Show`:

```idris
public export
data AuthorizationScheme : Type where
  BasicAuthorization : (credentials : String) -> AuthorizationScheme
  BearerAuthorization : (token : String) -> AuthorizationScheme

%runElab derive "AuthorizationScheme" [Generic, Meta, Eq, DecEq, Ord, Show]
```

Writing the header concatenates the token:

```idris
header_write_value Authorization =
  \case (BasicAuthorization creds) => "Basic " ++ creds
        (BearerAuthorization token) => "Bearer " ++ token
```

`Show` of a typed header pair is `key ++ ": " ++ value` — so `show` of an `Authorization` header **is the live Bearer line**. Source: https://github.com/idris-community/idris2-http/blob/master/src/Network/HTTP/Header.idr

`RawHttpMessage` / `HttpResponse` derive `Show` and keep `headers : List (String, String)`. Source: https://github.com/idris-community/idris2-http/blob/master/src/Network/HTTP/Message.idr

URL userinfo is also a shown `String` password:

```idris
public export
record URLCredential where
  constructor MkURLCredential
  username : String
  password : Maybe String

%runElab derive "URLCredential" [Eq, Show]
```

Source: https://github.com/idris-community/idris2-http/blob/master/src/Network/HTTP/URL.idr

**Nothing in this library prevents logging the token.** If you `printLn` the header list, the response, or a parsed `AuthorizationScheme`, the secret is on stdout. The practical rule: never `Show` the header list; pass `applyBearerAuth` only at the `request` call site.

## 2. `json` / `json-simple`: `ToJSON String` is identity encoding

```idris
public export
interface ToJSON a where
  constructor MkToJSON
  toJSON : forall v . Encoder v => a -> v

export
ToJSON String where toJSON = string

export
ToJSON a => ToJSON b => ToJSON (a, b) where
  toJSON (x,y) = array [toJSON x, toJSON y]
```

Source: https://github.com/stefan-hoeck/idris2-json/blob/main/src/JSON/ToJSON.idr

If a request/response record has an `apiKey : String` field and you `%runElab derive "Req" [ToJSON]`, the key is in the JSON. Safety is: **do not put the key on any `ToJSON` type**. An opaque key type with no `ToJSON` instance will fail to compile if someone adds it to a body record.

`idris2-json-schema` generates records from JSON Schema (already a custom dep here). Those records are document types, not credentials. Source: https://github.com/madman-bob/idris2-json-schema

## 3. `refined`: predicates, not redaction

Motivating example in the README **derives Show** for a refined `Alias` string — the value is printable:

```idris
record Alias where
  constructor MkAlias
  value : String
  {auto 0 prf : IsAlias value}

%runElab derive "Alias" [Show, Eq, RefinedString]
```

`IsAlias` is `Str $ Trimmed && Len (`LTE` MaxLen) && All PrintableAscii`. Source: https://github.com/stefan-hoeck/idris2-refined/blob/main/README.md

Useful predicates for a key **value** (optional):

- `Len` / `From 1` — non-empty (`Len` is `On` string length; `From` is `<=` on `Integer`). Sources: https://github.com/stefan-hoeck/idris2-refined/blob/main/src/Data/Refined/String.idr and https://github.com/stefan-hoeck/idris2-refined/blob/main/src/Data/Refined/Integer.idr
- `Trimmed`, `All PrintableAscii` — reject whitespace / junk

**Do not** refine the key as “starts with `Bearer `”. `applyBearerAuth` already prefixes `"Bearer " ++ token`. OpenRouter / TypeSafe keys are the raw token. Sources: Authorization.idr (above); OpenRouter curl uses `-H "Authorization: Bearer $OPENROUTER_API_KEY"` — https://openrouter.ai/docs/api/reference/authentication

`refined-json` would **encode** the refined string as JSON. That is the wrong direction for a secret.

## 4. `crypt` / `bcrypt`: hashing stored passwords, not API keys

`idris2-crypt` hashes passphrases with libxcrypt (`YesCrypt`, cost, `cryptcheck`). README: "one-way hashing of passphrases" for storing in a database. Source: https://github.com/stefan-hoeck/idris2-crypt/blob/main/README.md

You cannot hash an OpenRouter key and then send it as Bearer. These packages are irrelevant to the HTTP client.

## 5. Phantom / newtype distinction (language, no library)

Idris 2 erased parameters (`0 tag : Type`) distinguish keys without a runtime tag:

```idris
export data OpenRouter
export data TypeSafe

export
data ApiKey : Type -> Type where
  MkApiKey : String -> ApiKey a   -- constructor not exported
```

`ApiKey OpenRouter` and `ApiKey TypeSafe` do not unify, so you cannot pass a TypeSafe key to `applyBearerAuth` wrapped for OpenRouter. This is ordinary indexed data; no pack package required. Constructor hiding is the `export` vs `public export` rule above.

`newtype-deriving` is **not** in the catalog (commented out of HEAD.toml). You do not need it: write `Show` by hand.

# TYPESAFE / OPENROUTER (this project's keys)

This repo's motivating curl uses OpenRouter:

```
curl https://openrouter.ai/api/alpha/decisions \
  -H "Authorization: Bearer $OPENROUTER_API_KEY"
```

Source: `todo.md` in this repo.

OpenRouter docs: "Our API authenticates requests using Bearer tokens"; curl example is `-H "Authorization: Bearer $OPENROUTER_API_KEY"`; "Using environment variables and keeping keys out of your codebase is strongly recommended"; never commit keys. Source: https://openrouter.ai/docs/api/reference/authentication

TypeSafe (docs.typesafe.ai) specifies the **same HTTP scheme**, not an Idris library:

- OpenAPI: "Send your API key in the Authorization header as `Bearer <API_KEY>`"; `securitySchemes.HTTPBearer: { type: http, scheme: bearer }`. Source: https://docs.typesafe.ai/go/api.md
- Quickstart: store the key in `TYPESAFE_API_KEY`; Python/JS clients "Reads `TYPESAFE_API_KEY`"; bash `: "${TYPESAFE_API_KEY:?Set TYPESAFE_API_KEY first.}"`. Source: https://docs.typesafe.ai/introduction/quickstart.md
- Python SDK: `API_KEY_ENV = 'TYPESAFE_API_KEY'`. Source: https://docs.typesafe.ai/sdk/python/api/constants.md
- Python SDK logging: "`debug` also logs request and response headers and bodies. Secret headers — authorization, API keys, cookies, and any header whose name contains `token` or `secret` — are redacted from log output. Request and response bodies are not redacted." Source: https://docs.typesafe.ai/sdk/python/usage/advanced.md

TypeSafe's intro / primitives pages do **not** ship an Idris secret type. The first-party Idris client has to do env + Bearer itself. If this client talks to OpenRouter, the env name is `OPENROUTER_API_KEY` (OpenRouter docs + this repo's curl). If it later talks to `api.typesafe.ai` directly, the env name is `TYPESAFE_API_KEY`.

There is no Typesafe-owned Idris API-key library. Do not invent one.

# GAPS (evidence)

1. **No Idris 2 Secret / redacting API-key library in pack-db.** HEAD.toml has no `secret` / `secrets` / `credential` / `api-key` / `dotenv` / `env` / `redaction` keys. STATUS.md has no matching description. Wiki has none.
2. **No Secret in the compiler.** `prelude.ipkg` / `base.ipkg` / `contrib.ipkg` list no such module. `Show String` and `ToJSON String` are transparent.
3. **`getEnv` exists and returns `Maybe String`.** There is no `getenv` identifier; no dotenv; values are plain `String`.
4. **`idris2-http` does not protect tokens.** `applyBearerAuth : String -> (String, String)`; `AuthorizationScheme` derives `Show`; `RawHttpMessage` derives `Show` over raw headers; `URLCredential` derives `Show` over `password`.
5. **`refined` / `refined-json` are not secret types.** They constrain and (for json) **serialize** strings. README derives `Show` that prints the value.
6. **`crypt` / `bcrypt` / `hmac` hash or MAC; they cannot wrap a Bearer token you must send in the clear over TLS.**
7. **TypeSafe Python SDK redacts secret headers in logs; Idris `http` does not.** That redaction exists only in TypeSafe's Python client, not in Idris 2. Source: https://docs.typesafe.ai/sdk/python/usage/advanced.md vs Header.idr / Message.idr.
8. **Haskell gap (Idris absence only):** languages with a catalogued secret newtype (Haskell `Sensitive`/`Password`, etc.) have no pack-db counterpart. Confirmed by catalog search, not by a Haskell tutorial.

Closest building blocks (all first-party / pack-db / language):

- Opaque type: Idris 2 `export data` (constructors private) — https://idris2.readthedocs.io/en/latest/tutorial/modules.html
- Env load: `System.getEnv` — `libs/base/System.idr`
- Custom `Show` that ignores the value — `Prelude.Show`
- Do **not** implement `ToJSON` for the key — `JSON.ToJSON`
- Optional non-empty proof: pack `refined` (`Len (From 1)`)
- Phantom index: `ApiKey OpenRouter` vs `ApiKey TypeSafe` (language)
- Transport unwrap: `applyBearerAuth` at the `http` `request` site only

# RECOMMENDATION FOR typed-model-api

This repo is native Idris 2 (`typed-model-api.ipkg` depends on `json-schema`; HTTP research already points at pack `http` + `applyBearerAuth`). The key is an OpenRouter Bearer token from `$OPENROUTER_API_KEY` (`todo.md`, OpenRouter auth docs).

**Do this (no new pack dep for secrets):**

1. One small module, e.g. `src/OpenRouter/Key.idr`. Use `export data` so the constructor stays private (`export` ≠ `public export`).

```idris
module OpenRouter.Key

import System
import Network.HTTP.Authorization

%default total

export
data OpenRouterKey : Type where
  MkOpenRouterKey : String -> OpenRouterKey

export
Show OpenRouterKey where
  show _ = "OpenRouterKey <redacted>"

||| Load from the process environment. Nothing if unset or empty.
export
fromEnv : HasIO io => io (Maybe OpenRouterKey)
fromEnv = do
  m <- getEnv "OPENROUTER_API_KEY"
  pure $ case m of
    Just s => if null s then Nothing else Just (MkOpenRouterKey s)
    Nothing => Nothing

||| Only exported way to turn the key into an HTTP header.
export
bearerHeader : OpenRouterKey -> (String, String)
bearerHeader (MkOpenRouterKey token) = applyBearerAuth token
```

Shaped from: `System.getEnv` / `Data.String.null` / `applyBearerAuth` (sources above). Do **not** add `ToJSON OpenRouterKey`. Do **not** `%runElab derive "OpenRouterKey" [Show]` or `[ToJSON]`.

2. Call site (from the HTTP note): pass `bearerHeader key` in the header list; never `printLn` that list or the `HttpResponse` headers if they could echo `Authorization`.

```idris
Just key <- fromEnv
  | Nothing => die "OPENROUTER_API_KEY is not set"

(response, content) <- request client POST
  (url' "https://openrouter.ai/api/alpha/decisions")
  [ ("Content-Type", "application/json")
  , bearerHeader key
  ]
  (encode requestBody)
```

3. Phantom tag only if a second vendor key appears (`ApiKey OpenRouter` vs `ApiKey TypeSafe`). One vendor → a single `OpenRouterKey` is enough.

4. Optional: pack `refined` for `Len (From 1)` / printable-ASCII at `fromEnv`. Skip `refined-json`. Skip `crypt`/`bcrypt`. Skip dotenv — `getEnv` is the catalog answer.

**Do not** store the key on json-schema-generated request records. **Do not** `show` / `printLn` `RawHttpMessage`, `HttpResponse`, or `List (String, String)` headers. **Do not** expect `idris2-http` or TypeSafe docs to give you an Idris secret type — they do not.
