# REF

- Pack catalog: https://github.com/stefan-hoeck/idris2-pack-db/blob/main/STATUS.md
- Pack HEAD collection: https://github.com/stefan-hoeck/idris2-pack-db/blob/main/collections/HEAD.toml
- Idris 2 wiki third-party list: https://github.com/idris-lang/Idris2/wiki/Third-party-Libraries
- Idris 2 `network` package: https://github.com/idris-lang/Idris2/blob/main/libs/network/network.ipkg
- Idris 2 `Network.Socket`: https://github.com/idris-lang/Idris2/blob/main/libs/network/Network/Socket.idr
- Idris 2 `contrib` (JSON, no HTTP): https://github.com/idris-lang/Idris2/blob/main/libs/contrib/contrib.ipkg
- HTTP/1.1 client: https://github.com/idris-community/idris2-http
- HTTP types + API combinators: https://github.com/stefan-hoeck/idris2-http-types
- Servant-inspired REST demo: https://github.com/running-grass/idris2-pact
- libcurl FFI (not in pack-db): https://github.com/MarcelineVQ/idris2-curl
- libcurl easy FFI (not in pack-db): https://github.com/wchresta/idris2-curl
- JSON marshalling: https://github.com/stefan-hoeck/idris2-json
- JSON Schema codegen (already a custom pack dep here): https://github.com/madman-bob/idris2-json-schema
- URL parser: https://github.com/running-grass/idris2-url
- TLS used by `http`: https://github.com/idris-community/idris2-tls
- Node web *server* (not a client): https://github.com/kbertalan/tyttp

# MAIN

**Short answer:** Idris 2 has no official HTTP/curl client in the compiler. The pack-db catalog *does* have a native HTTP/1.1 client (`http` = idris-community/idris2-http) that types Method/URL/Header/Response and sends String/bytes bodies over sockets+TLS — it does not wrap libcurl. Servant/OpenAPI-style request typing exists in pack-db (`http-types` / `pact-api`) but neither is a production curl-typed client: `http-client-api` talks to the browser's `XMLHttpRequest`, and `pact-client` is a demo that only fully implements GET. libcurl bindings exist on GitHub and are **not** in pack-db.

For this project (native Idris 2, `pack.toml`, already depending on json-schema): use pack `http` as transport, json-schema-generated records + `json`/`json-simple` for the body, and type the OpenRouter path/headers yourself (or reuse `HTTP.API` combinators as types only).

# PACK-DB: what exists

Searched `collections/HEAD.toml` and `STATUS.md` for `http`, `http-client`, `curl`, `idris2-http`, `idris2-curl`, `fetch`, `network`, `requests`, `uri`, `url`, `openapi`, `json-schema`. Hits below. **No `curl`, `fetch`, `requests`, `openapi`, or `json-schema` package names appear in HEAD.toml.**

## In pack-db (canonical catalog)

| Pack name | Repo | STATUS.md description | Transport | Types |
| --- | --- | --- | --- | --- |
| `http` | https://github.com/idris-community/idris2-http | "A http client implementation in idris2" | `Network.Socket` + `tls` | `Method`, `URL`, `Header`, `RawHttpMessage`, `HttpResponse`; body via `Bytestream` (`()`, `String`, `List Bits8`) |
| `http-types` | https://github.com/stefan-hoeck/idris2-http-types | "Types and utilities for working with HTTP requests and responses" | none (types only) | `HTTP.API`: `ReqPath`, `ReqQuery`, `ReqHeaders`, `ReqContent`, `ReqMethod`, `URI`, `Method`, `Status` |
| `http-client-api` | same repo, `http-client-api/` | "Client-side interpreter for HTTP API" | **browser `XMLHttpRequest`** (`async-js`, `dom`) | interprets `HTTP.API` endpoints |
| `http-server-api` | same repo, `http-server-api/` | "Server-side interpreter for HTTP API" | server-side | same combinators |
| `pact-api` | https://github.com/running-grass/idris2-pact | "A Type-safe REST API framework inspired by Servant" | types | `StaticPath` / `Capture` / `ReqBody` `:>` `Get`/`Post` |
| `pact-client` | same | "Client generated for Pact API" | depends on pack `http` | generates GET links; `ReqBody` client path crashes |
| `url` | https://github.com/running-grass/idris2-url | "A url library for idris2" | none | RFC 1738 URL parse/stringify (WIP) |
| `tls` | https://github.com/idris-community/idris2-tls | "A portable idris2 implementation of TLS" | TLS over sockets | used by `http` |
| `network` | https://github.com/idris-lang/Idris2 (`libs/network`) | (bundled) | POSIX sockets | `Network.Socket` |
| `json` / `json-simple` | https://github.com/stefan-hoeck/idris2-json | derivable JSON marshallers | none | `ToJSON` / `FromJSON` |
| `tyttp` / `tyttp-json` | https://github.com/kbertalan/tyttp | experimental **web server** for Node | Node HTTP *server* | routing, JSON payloads — not a client |
| `http2` | https://git.sr.ht/~janus/http2 | "Continuation based HTTP2 **server**. No IO." | used by `web-server-racket` | server, not a client |

HEAD.toml entries (pack names are the install names):

```toml
[db.http]
type   = "github"
url    = "https://github.com/idris-community/idris2-http"
commit = "master"
ipkg   = "http.ipkg"

[db.http-client-api]
type   = "github"
url    = "https://github.com/stefan-hoeck/idris2-http-types"
commit = "main"
ipkg   = "http-client-api/http-client-api.ipkg"

[db.http-types]
type   = "github"
url    = "https://github.com/stefan-hoeck/idris2-http-types"
commit = "main"
ipkg   = "http-types.ipkg"

[db.pact-api]
type   = "github"
url    = "https://github.com/running-grass/idris2-pact"
commit = "main"
ipkg   = "api/pact-api.ipkg"

[db.pact-client]
type   = "github"
url    = "https://github.com/running-grass/idris2-pact"
commit = "main"
ipkg   = "client/pact-client.ipkg"
```

Sources: https://github.com/stefan-hoeck/idris2-pack-db/blob/main/collections/HEAD.toml and https://github.com/stefan-hoeck/idris2-pack-db/blob/main/STATUS.md

`stellar-http` exists in the Stellar repo but is **commented out** of HEAD.toml (`# [db.stellar-http]`).

## Not in pack-db (GitHub / wiki only)

| Package | Repo | Why it is not the catalog answer |
| --- | --- | --- |
| `curl` (MarcelineVQ) | https://github.com/MarcelineVQ/idris2-curl | libcurl Easy/Multi FFI. README: "I really don't want to write my own HTTP lib, so here's curl." Not in HEAD.toml / STATUS.md. |
| `curl` (wchresta) | https://github.com/wchresta/idris2-curl | Primitive libcurl easy wrapper; "very early development". Not in pack-db. |
| `idris2-http-async` | https://github.com/reilysiegel/idris2-http-async | WIP fork of `idris2-http`; not in pack-db. |
| `json-schema` | https://github.com/madman-bob/idris2-json-schema | Codegen from JSON Schema → Idris records. Listed on the Idris 2 wiki under Data science, **not** in pack-db. This project already vendors it via `[custom.all.json-schema]` in `pack.toml`. |

Wiki Network section lists only `idris2-tls`. Wiki Web section lists only `tyttp` (Node server). The HTTP *client* is in pack-db but not on the wiki page. Source: https://github.com/idris-lang/Idris2/wiki/Third-party-Libraries

# IDRIS 2 ITSELF: IO / network, no HTTP

The compiler ships these libraries under `libs/`: `prelude`, `base`, `contrib`, `linear`, `network`, `papers`, `test`. There is no HTTP package. Source: https://github.com/idris-lang/Idris2/tree/main/libs

`network` is its own package (not `base`/`contrib`):

```
package network
modules = Control.Linear.Network,
          Network.Socket,
          Network.Socket.Data,
          Network.Socket.Raw,
          Network.FFI
depends = linear
```

Source: https://github.com/idris-lang/Idris2/blob/main/libs/network/network.ipkg

`Network.Socket` is documented as **low-level C sockets**, "Used by higher-level, cleverer things." API: `socket`, `bind`, `connect`, `listen`, `accept`, `send`/`recv` (String), `sendBytes`/`recvBytes`/`recvAllBytes`. No HTTP framing. Source: https://github.com/idris-lang/Idris2/blob/main/libs/network/Network/Socket.idr

`contrib` includes `Language.JSON` (lexer/parser) and no HTTP modules. Source: https://github.com/idris-lang/Idris2/blob/main/libs/contrib/contrib.ipkg

Pack STATUS.md lists compiler `network` as the Idris2 commit, same as `base`/`contrib`.

# HOW TYPING WORKS IN EACH LIBRARY

## 1. Generic HTTP client: `http` (idris-community/idris2-http)

This is the pack-installable **native** client. It is HTTP/1.1, keep-alive, gzip/zlib, TLS, streaming. It depends on `network` and `tls` (`http.ipkg`). Connections are created with `Network.Socket.socket AF_INET Stream 0` then `connect`. Source: https://github.com/idris-community/idris2-http/blob/master/src/Network/HTTP/Pool/ConnectionPool.idr

**What it types**

- `Method`: `GET | HEAD | POST | PUT | DELETE | CONNECT | OPTIONS | PATCH | Custom String` — https://github.com/idris-community/idris2-http/blob/master/src/Network/HTTP/Method.idr
- `URL`: `protocol`, `credential`, `host` (`Hostname` = domain + optional port), `path`, `extensions` (query/fragment as a leftover `String`). Compile-time proof that a string literal starts with `http://` or `https://` via `url'`. — https://github.com/idris-community/idris2-http/blob/master/src/Network/HTTP/URL.idr
- `Header`: enumeration (`Host`, `ContentType`, `Authorization`, …) with `header_value_type : Header -> Type` (e.g. `Authorization` → `AuthorizationScheme` = Basic | Bearer). The **client `request` API still takes `List (String, String)`**, not the typed `Headers`. — https://github.com/idris-community/idris2-http/blob/master/src/Network/HTTP/Header.idr
- `RawHttpMessage` / `HttpResponse` (status code as `DPair Nat StatusCode`, headers as `List (String, String)`). — https://github.com/idris-community/idris2-http/blob/master/src/Network/HTTP/Message.idr
- Body: `Bytestream a` with instances for `()`, `List Bits8`, `String`. **No JSON codec in this library.**

**Practical API (from the library's own test, primary source)**

GET:

```idris
(response, content) <- request client GET (url' "http://openbsd.org/70.html") [] ()
```

POST (body is a `String`):

```idris
let body = "this is the body"
(response, content) <- request client POST (url' "https://httpbin.org/post") [] body
```

Bearer header:

```idris
let token = "YWxhZGRpbjpvcGVuc2VzYW1l"
    bearerauth = applyBearerAuth token
(response, content) <- request client GET (url' "https://httpbin.org/bearer") [bearerauth] ()
```

Sources:
- https://github.com/idris-community/idris2-http/blob/master/tests/src/ClientTest.idr
- `request` signature: https://github.com/idris-community/idris2-http/blob/master/src/Network/HTTP/Client.idr
- `applyBearerAuth : String -> (String, String)`: https://github.com/idris-community/idris2-http/blob/master/src/Network/HTTP/Authorization.idr

This is **not** Servant/OpenAPI typing: path/query/body/response are not Idris types of the API. It is a generic HTTP client with typed Method + URL + optional typed Header lookup, and untyped String headers/body at the call site.

## 2. Servant-style combinators: `http-types` / `http-client-api`

`http-types.ipkg` brief: "Types and utilities for working with HTTP requests and responses". Modules include `HTTP.API.{Content,Endpoints,Decode,Encode,Header,Method,Path,Query}`, `HTTP.URI`, `HTTP.Method`, `HTTP.Status`. Source: https://github.com/stefan-hoeck/idris2-http-types/blob/main/http-types.ipkg

This **does** type path/query/body/response as Idris types:

- Path: `Part` = `PStr` | `Capture (0 t : Type)` | scheme/auth; `ReqPath`. Captured types become handler arguments. — https://github.com/stefan-hoeck/idris2-http-types/blob/main/src/HTTP/API/Path.idr
- Query: `name ?? Type` and `QBool name`. — https://github.com/stefan-hoeck/idris2-http-types/blob/main/src/HTTP/API/Query.idr
- Body: `ReqContent` with `JSONContent : Type -> ReqContent` = `Content [JSON]`. — https://github.com/stefan-hoeck/idris2-http-types/blob/main/src/HTTP/API/Content.idr
- Verb: `Get formats val`, `Post formats val`, etc. (`ReqMethod` carries method, status, response formats, result type). — https://github.com/stefan-hoeck/idris2-http-types/blob/main/src/HTTP/API/Method.idr
- JSON body encoding: `ToJSON a => EncodeVia a JSON` with `mediaType = applicationJSON`. — https://github.com/stefan-hoeck/idris2-http-types/blob/main/src/HTTP/API/Encode.idr
- URI parser/encoder (`HTTP.URI`, `HTTP.Parser.URI`).

**Client interpreter is JS-only.** `http-client-api.ipkg`:

```
depends = http-types, async-js, dom
```

FFI is `%foreign "browser:lambda:..."` wrapping `XMLHttpRequest` / `FormData`. `opn` calls `x.open(me,url)`. Source: https://github.com/stefan-hoeck/idris2-http-types/blob/main/http-client-api/src/HTTP/API/Client/FFI.idr

Client send:

```idris
requestJSONEndpoint : (0 t : Type) -> DecodeVia JSON t => Async JS es t
```

Source: https://github.com/stefan-hoeck/idris2-http-types/blob/main/http-client-api/src/HTTP/API/Client.idr

So: this is the closest **type-level** HTTP API (Servant-like), but it cannot drive the OpenRouter curl from a native Idris 2 process. The types package can still be used without the JS client.

## 3. Servant-inspired REST demo: `pact-api` / `pact-client`

README: "Now it's just a simple demo. Not ready for production." Acknowledgements: Servant, Stefan Höck. Source: https://github.com/running-grass/idris2-pact/blob/main/README.md

API shape (from the TodoMVC example in-tree):

```idris
ApiGetTodos : API
ApiGetTodos = StaticPath "todos" :> Get JSONAccept (List Todo)

ApiGetTodo : API
ApiGetTodo = StaticPath "todos" :/ Capture "id" TodoId :> Get JSONAccept Todo

ApiPostTodo : API
ApiPostTodo = StaticPath "todos" :/ ReqBody Todo :> Post JSONAccept Todo
```

Source: https://github.com/running-grass/idris2-pact/blob/main/todomvc/src/TodoMVC/Api.idr

`pact-client` **depends on pack `http`** (`pact-client.ipkg`). The generated client currently:

- implements `get : URL -> Result String` via `request client GET url [] ()`
- `generateLink (ReqBody _ :/ _) = assert_total $ idris_crash "ReqBody is not supported"`

Sources:
- https://github.com/running-grass/idris2-pact/blob/main/client/pact-client.ipkg
- https://github.com/running-grass/idris2-pact/blob/main/client/src/Pact/Client/Core.idr

So pact is the catalog's Servant analogue, but the client is GET-only and the project itself says it is a demo.

## 4. libcurl FFI (not pack-db)

### MarcelineVQ/idris2-curl (package name `curl`)

README: Easy + Multi interfaces; "methods to use curl as a replacement for Idris' `network` package when used for internet connections." Source: https://github.com/MarcelineVQ/idris2-curl/blob/master/README.md

High-level helper is **untyped URL → String body**:

```idris
easyFetchUrl : HasIO io => (url : String) -> io (Either CurlECode String)
```

setopt takes `CurlEOption ty` (dependently typed option → param). Example:

```idris
CURLE_OK <- curlEasySetopt cli CURLOPT_URL "https://www.google.com/"
```

Sources:
- https://github.com/MarcelineVQ/idris2-curl/blob/master/src/Network/Curl/Easy.idr
- https://github.com/MarcelineVQ/idris2-curl/blob/master/examples/captureResponse.idr

This types **libcurl options**, not HTTP Method/path/query/JSON body.

### wchresta/idris2-curl

README: "wrappers around libcurl's easy interfaces that are very close to the C interface but also reasonably type-safe"; "safe types for `curl_easy_setopt`"; "very early development". Source: https://github.com/wchresta/idris2-curl/blob/master/README.md

```idris
curl_easy_setopt : Curl -> (curlOpt : CurlOpt) -> parameterType curlOpt -> IO CurlCode
```

Test GET:

```idris
curl <- curl_easy_init
CurlEOk <- curl_easy_setopt curl CurlOptUrl "https://www.google.com"
CurlEOk <- curl_easy_perform curl
```

Sources:
- https://github.com/wchresta/idris2-curl/blob/master/src/Network/Curl/Easy.idr
- https://github.com/wchresta/idris2-curl/blob/master/test/Main.idr

Same gap: typed curl options, not typed HTTP requests.

## 5. JSON Schema / JSON (body codecs, not HTTP)

`idris2-json-schema` **generates records from a JSON Schema file**; it is an executable (`main = JSONSchema`), not an HTTP client. Example output is `record Main` with `title : String`, `year : Double`. Source: https://github.com/madman-bob/idris2-json-schema/blob/main/README.md and https://github.com/madman-bob/idris2-json-schema/blob/main/json-schema.ipkg

`idris2-json` derives `ToJSON`/`FromJSON` (aeson-style). Source: https://github.com/stefan-hoeck/idris2-json/blob/main/README.md

`contrib`'s `Language.JSON` is a parser/AST only.

There is no OpenAPI→Idris generator in pack-db. Wiki lists json-schema as a Data science codegen tool, not as HTTP.

# GAPS (evidence)

1. **No curl-typed HTTP library in pack-db.** `HEAD.toml` has no `curl` / `idris2-curl` / `fetch` / `requests` / `openapi` keys. STATUS.md has no curl row. Wiki Network section has only TLS.
2. **No official compiler HTTP client.** `libs/` has `network` sockets only; `contrib.ipkg` has `Language.JSON` and no HTTP modules.
3. **No library that both (a) types path/query/body/response as Idris types and (b) runs them as a native curl/HTTP process.** `http-types` does (a) with a JS client; `http` does native IO without (a); `pact` attempts both but is a GET-only demo that crashes on `ReqBody`.
4. **json-schema is not in pack-db**; this repo already adds it as `custom.all.json-schema`. It types JSON *documents*, not HTTP.

Closest building blocks (all first-party / pack-db / already depended):

- Transport: pack `http` (sockets + `tls`)
- URI: `http`'s `Network.HTTP.URL` or pack `url` or `HTTP.URI` in `http-types`
- Method/Header/Status: `http` or `http-types`
- JSON body types: json-schema codegen (this repo) + pack `json` / `json-simple`
- Sockets fallback: Idris2 `network` (`Network.Socket`)
- libcurl fallback (uncurated): MarcelineVQ or wchresta `idris2-curl`

# RECOMMENDATION FOR typed-model-api

This repo is native Idris 2 (`typed-model-api.ipkg` depends on `json-schema`; `pack.toml` already pins madman-bob/idris2-json-schema). The motivating curl is a POST to `https://openrouter.ai/api/alpha/decisions` with `Content-Type: application/json` and `Authorization: Bearer …` (`todo.md`).

**Do this:**

1. Add pack `http` as the transport (`depends = json-schema, http` plus `json` or `json-simple` for marshalling). Install via pack; no custom git pin needed — it is in HEAD.toml.
2. Generate (or hand-write) request/response records with the existing json-schema toolchain; derive `ToJSON`/`FromJSON` via `json`/`json-simple`.
3. Call the client like the library's own POST + bearer tests:

```idris
(response, content) <- request client POST
  (url' "https://openrouter.ai/api/alpha/decisions")
  [ ("Content-Type", "application/json")
  , applyBearerAuth token
  ]
  (encode requestBody)   -- String from ToJSON
```

4. Optionally describe the endpoint with `http-types` combinators (`Path ["api","alpha","decisions"]`, `JSONContent DecisionRequest`, `Post [JSON] DecisionResponse`) **as types only**. Do not depend on `http-client-api` unless targeting the JS backend.

**Do not** pick `pact-client` for this POST (it `idris_crash`es on `ReqBody`). **Do not** pick MarcelineVQ/wchresta curl unless you specifically need libcurl features (proxies, HTTP/2 via curl, etc.) — they are uncurated and type curl options, not the OpenRouter API. **Do not** expect the compiler's `Network.Socket` to speak HTTPS; `http` already layers `tls` on top of it.
