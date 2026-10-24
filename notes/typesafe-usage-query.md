# How TypeSafe usage is queried (console, public API, websockets)

There is **no official public API** to poll org/account spend, remaining credits, rate-limit remaining, or request history as shown on `https://console.typesafe.ai/usage`. The published HTTP API (`https://api.typesafe.ai`) exposes only `POST /v1/systemone` and `GET /v1/models`. Each successful System One response **does** include per-request `usage.input_tokens` / `usage.output_tokens` (input is billable; output is currently free). Rate limits are org-scoped and documented as returning HTTP 429 with an optional `retry-after` / `retry-after-ms` header; remaining quota is **not** documented as a header or endpoint. The Usage page itself is **console-session-gated**: unauthenticated `GET /usage` 307s to `/login?returnTo=%2Fusage`. The console **does** have an undocumented private REST endpoint `GET https://console.typesafe.ai/api/usage` that answers unauthenticated callers with RFC 7807 `401 {"title":"Unauthenticated","status":401,"code":"unauthenticated"}` and `Allow: GET, HEAD, OPTIONS` — session cookies, not a Bearer API key. No documented or observed usage WebSocket, SSE stream, or live daemon exists in OpenAPI, SDK types, or the public GitHub org. Reconstructing spend from per-response `usage` fields is the only official programmatic path.

## Findings (with citations)

### Public docs index

`https://docs.typesafe.ai/llms.txt` (fetched 2026-10-24) is the live docs catalog. Pages whose titles or descriptions mention usage, billing, rate limits, tokens, dashboard/console, or streaming:

| Page | What it actually says |
| --- | --- |
| [Models](https://docs.typesafe.ai/models.md) / [go/models.md](https://docs.typesafe.ai/go/models.md) | Price `$42 / Btok = $0.042 / Mtok` input; output tokens free. Rate limits per organization, measured in tokens/s and requests/s; current limits “are in the developer console”; over limit → `429`. SDKs retry and follow `retry-after` when present. Higher limits: `sales@typesafe.ai`. |
| [System One](https://docs.typesafe.ai/api/system-one.md) / [go/api.md](https://docs.typesafe.ai/go/api.md) | `POST /v1/systemone`. “The response also includes the model used and token usage.” Required response fields: `model`, `answers`, `usage`. |
| [Request rules and errors](https://docs.typesafe.ai/api/errors.md) | Status table: `400`, `401`, `413`, `415`, `422`, `429`, `529`. **No `402`.** Rate-limit handling: exponential backoff; SDKs handle it. |
| [Quick start](https://docs.typesafe.ai/introduction/quickstart.md) | `Authorization: Bearer <API_KEY>`. Example raw JSON includes `"usage": {"input_tokens": 428, "output_tokens": 73}`. “Get an API key from the TypeSafe console.” |
| [List models](https://docs.typesafe.ai/api/list-models.md) | `GET /v1/models` only. Bearer auth. |
| [JS `Usage`](https://docs.typesafe.ai/sdk/javascript/api/interfaces/Usage.md) | `input_tokens: number \| null`, `output_tokens: number \| null`. |
| [JS `SystemOneResult`](https://docs.typesafe.ai/sdk/javascript/api/interfaces/SystemOneResult.md) | Required `usage: Usage`. |
| [JS `TypeSafeClient`](https://docs.typesafe.ai/sdk/javascript/api/classes/TypeSafeClient.md) | Methods: `systemOne`, `models.list`. No usage/billing resource. |
| [JS `RateLimitError`](https://docs.typesafe.ai/sdk/javascript/api/classes/RateLimitError.md) | HTTP 429. `retryAfterMs` from headers. `requestId` from `x-typesafe-request-id`. |
| [JS `RetryPolicy`](https://docs.typesafe.ai/sdk/javascript/api/interfaces/RetryPolicy.md) | Honors `Retry-After` and `retry-after-ms`. Default retry statuses include 429. |
| [Python answers/responses](https://docs.typesafe.ai/sdk/python/api/types/responses.md) | `SystemOneResponse.usage: Usage`; `input_tokens` / `output_tokens` may be `None`. `request_id` from `x-typesafe-request-id`. |
| [Python exceptions](https://docs.typesafe.ai/sdk/python/api/exceptions.md) | `TypeSafeRateLimitError` (429) with `retry_after_ms`. No usage-query client. |
| [Python retries](https://docs.typesafe.ai/sdk/python/api/retries.md) | `respect_retry_after` honors `Retry-After` and `retry-after-ms`. |
| [Python SDK](https://docs.typesafe.ai/sdk/python.md) / [async client](https://docs.typesafe.ai/sdk/python/api/clients/async.md) | `system_one` and `models.list` only. |
| [Python “Basic usage”](https://docs.typesafe.ai/sdk/python/usage/basic.md) | SDK how-to, **not** billing/usage analytics. |
| [JS SDK](https://docs.typesafe.ai/sdk/javascript.md) / [go/js-sdk.md](https://docs.typesafe.ai/go/js-sdk.md) | Same: `systemOne` + `models`. |
| [Legal](https://docs.typesafe.ai/legal.md) | Points at MCA / DPA / Privacy Policy. |

No llms.txt page is titled usage dashboard, billing API, websocket, SSE, streaming inference, analytics, quota, or metrics. Inference is a single JSON POST, not a stream.

### Help Center (first-party)

- [What’s a 402 error?](https://help.typesafe.ai/articles/5505198974-what-s-a-402-error-and-how-can-i-add-more-credits): “A 402 error usually means there are not enough credits available for the request.” Fix is console → organization → Settings → Billing → Available credits → Add funds. Billing history is a console UI, not an API. (Public errors.md does **not** list 402.)
- [How do I add credits?](https://help.typesafe.ai/articles/7771619341-how-do-i-add-credits): Admin-only; Settings → Billing; optional automatic top-ups.
- [Billing, payments, and credits collection](https://help.typesafe.ai/collections/4550307150-billing_payments_and_credits): only “How do I add credits?” and the refund policy. No usage-page article.
- [Do you offer higher rate limits?](https://help.typesafe.ai/articles/7646730650-do-you-offer-higher-rate-limits): email `sales@typesafe.ai` with Org ID, traffic shape, desired RPS and TPS.
- [429 vs 529](https://help.typesafe.ai/articles/2769560962-what-is-the-difference-between-429-and-529): 429 = exceeded a rate limit; 529 = TypeSafe overloaded. Honor a retry-after header when returned. “Review the current model limits.”
- [Who should I reach out to?](https://help.typesafe.ai/articles/8737694518-who-should-i-reach-out-to-with-support-requests): console/billing → `support@typesafe.ai`; higher rate limits → `sales@typesafe.ai`.

No Help Center article found that documents a public usage query API, a websocket, or how the Usage page is populated.

### Legal / contracts

[Master Customer Agreement](https://typesafe.ai/legal/mca) (2026-09-23):

- §1: Services = Web Interface at `https://console.typesafe.ai` **and** the API.
- §2.4: designated access is **API key for the API** and **username and password for the Web Interface**.
- §8.2: TypeSafe-managed Credits consumed per Input; “Customer may view Customer’s current Credit balance in Customer’s account.” Consumption rate may vary by model/account settings as indicated on the Services. No API for the balance is named.
- §2.3(g)/(k): no circumventing access restrictions; access only as permitted in the Agreement and Documentation.
- §2.1 “Usage Limits” are Order-defined contractual limits, not an HTTP resource.

[Acceptable Use Policy](https://typesafe.ai/legal/acceptable-use-policy) §3.2: do not “access the Services through unauthorized means (e.g., scraping or crawling).” §3.3: do not circumvent security (CAPTCHA). §3.6: do not “monitor traffic on the Services without TypeSafe’s permission.”

### Status page

[status.typesafe.ai](https://status.typesafe.ai) (fetched 2026-10-24) monitors `api.typesafe.ai` and `console.typesafe.ai` as **separate** services, plus regional API hosts (`api.us.typesafe.ai`, `api.us-east-1.typesafe.ai`, …). It is availability, not usage.

---

## Console Usage page: how it loads data

### Login is required

Observed 2026-10-24 (curl, Firefox UA, no session):

```
GET https://console.typesafe.ai/usage
→ HTTP/2 307
location: /login?returnTo=%2Fusage
set-cookie: session=; … Max-Age=0
set-cookie: session_id=; … Max-Age=0
set-cookie: organization_id=; … Max-Age=0
(+ hook_pending, first_user_of_org_id, console_survey_pending, all cleared)
```

Following the redirect yields the login HTML titled “TypeSafe” / “Welcome to TypeSafe / Sign in or create an account through Google or your email” (same copy from WebFetch of `/usage`).

An RSC-style request (`RSC: 1`) to `/usage` also 307s to `/login?returnTo=%2Fusage`. The page is console-session-gated. **No login was attempted** and no auth bypass was tried.

Playwright MCP (`plugin-playwright-playwright`) was **Cloudflare-blocked** (`403 Attention Required! | Cloudflare`, Ray `a4fbc82e9e973198`). The network-tab inspection the prompt asked for could not be done in that browser. Curl from this environment reached the origin.

### Stack (from response headers and HTML)

- `x-powered-by: Next.js`
- `vary: rsc, next-router-state-tree, next-router-prefetch, next-router-segment-prefetch`
- `x-envoy-decorator-operation: devsite-frontend.devsite-frontend.svc.cluster.local:3000/*` (k8s Next.js on :3000 behind Envoy + Cloudflare)
- `data-dpl-id="ec82103862ff53b580bab734425a47aa68c4aa6f"` (Vercel-style deployment id; also returned by public `GET /api/version` → `{"version":"ec82103862ff53b580bab734425a47aa68c4aa6f"}`)
- Scripts under `/_next/static/chunks/…?dpl=…` (Turbopack)
- CSP: `connect-src 'self' https: wss:;` (allows HTTPS and WSS to any host; this is a policy, not proof a usage socket exists)

First-party confirmation that console auth is Next.js **server actions**, not a public JSON auth API: [typesafe-ai/skills#10](https://github.com/typesafe-ai/skills/issues/10) (user report, 2026-09-21). The reporter captured `POST /login` with `$ACTION_REF_*` multipart fields; `GET /login` had no `Set-Cookie`; `/api/auth/providers`, `/api/auth/session`, `/api/auth/csrf`, `/.well-known/openid-configuration` fell through to login HTML. This research reproduced the last point: those NextAuth-style paths 307 to `/login` as HTML, they are not live JSON auth endpoints.

### Auth is Stytch + session cookies, not Clerk

Login HTML `window.__APP_RUNTIME_CONFIG__` (public, inlined):

```json
{
  "POSTHOG_KEY": "phc_WPXBSDV59U6jCvjp8nRaBLABHpHMgomLfKckkldgyHf",
  "STRIPE_PUBLISHABLE_KEY": "pk_live_51PGmnEP0QWPRZPIB1V2vrfBAARTHilwIbtXxm0nvNMQ0TziW3CVvlsZuVScnRHZCx8MI1ew6dCjNXezbGcjOlDwx00Zaxmmtv7",
  "STYTCH_PUBLIC_TOKEN": "public-token-live-620c0996-4644-4af3-b592-31cb05006523",
  "STYTCH_TELEMETRY_SUBMIT_URL": "https://auth.typesafe.ai/submit",
  "TURNSTILE_SITE_KEY": "0x4AAAAAAFC7B8Sagsv-IhSV",
  "TS_ENV": "prod",
  "APP_VERSION": "ec82103862ff53b580bab734425a47aa68c4aa6f"
}
```

Also preloaded: `https://login.typesafe.ai/telemetry.js`, Cloudflare Turnstile `https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit`.

Evidence against Clerk: `clerk.typesafe.ai` does not resolve (curl NXDOMAIN). Login JS contains `STYTCH_PUBLIC_TOKEN` / `x-stytch-telemetry-id` and zero `clerk` string matches. Stripe publishable key is present (billing checkout in the console, matching Help Center “Add funds”).

Session cookies the unauthenticated `/usage` response clears: `session`, `session_id`, `organization_id` (all `Secure; HttpOnly; SameSite=lax`).

### Private console HTTP API (undocumented; session-gated)

Probing `https://console.typesafe.ai/api/…` without credentials, classifying **real JSON APIs** (401 JSON) vs Next.js HTML 307 fallbacks:

| Path | Unauthenticated result |
| --- | --- |
| `GET /api/usage` and `GET /api/usage/` | **401** `Content-Type: application/problem+json` body `{"title":"Unauthenticated","status":401,"code":"unauthenticated"}`; header `x-error-code: unauthenticated` |
| `GET /api/usage?range=7d`, `?from=2026-10-01` | same 401 problem+json (query is accepted at the router; 200 shape unknown) |
| `OPTIONS /api/usage` | **204** `Allow: GET, HEAD, OPTIONS` |
| `GET /api/api-keys` and `/api/api-keys/` | same 401 problem+json as `/api/usage` |
| `GET /api/me` | **401** `application/json` `{"error":"Unauthorized","code":"session_expired"}` (different body shape — likely a Next.js BFF vs the problem+json backend) |
| `GET /api/version` | **200** `{"version":"<dpl id>"}` (public) |
| `POST /api/auth/callback` | **405** (exists; POST-only; named in login JS) |
| `POST /api/test/session` | **405** (named in login JS; looks like a test helper) |
| Guessed siblings (`/api/billing`, `/api/credits`, `/api/metrics`, `/api/requests`, `/api/ws`, `/api/stream`, `/api/sse`, `/api/usage/history`, `/api/usage/summary`, `/api/rate-limits`, `/api/quotas`, …) | **307** HTML to `/login` (Next.js catch-all — these paths are **not** live APIs in this probe) |

Login-page JS (`/_next/static/chunks/0zt8pe_4fxezk.js`) calls `devsiteApiFetch("/api/me")` and `devsiteApiJson("/api/auth/callback", { method: "POST", … })`. The Usage **page** chunk is not in the unauthenticated login bundle (code-split), so the exact client call that hydrates `/usage` was not in those 22 login scripts. The matching private REST resource is nonetheless `GET /api/usage` on the console origin.

Bearer `Authorization: Bearer dummy` on `GET /api/usage` still 401 problem+json — this console route does not treat a dummy API key as a session. Forged `Cookie: session=dummy; session_id=dummy; organization_id=dummy` also 401. So the gate is a **real console session**, not the public `TYPESAFE_API_KEY`.

`Accept: text/event-stream` on `GET /api/usage` still returns `application/problem+json` 401, not an SSE stream.

**200 response shape of `/api/usage` was not observed** (would require a logged-in session). Do not treat the 401 schema as the success schema.

---

## Public API / OpenAPI: presence or absence of usage endpoints

Fetched `https://api.typesafe.ai/openapi.json` (OpenAPI 3.1, title TypeSafe, version **0.2.0**, server `https://api.typesafe.ai`).

**Every path:**

| Method | Path | Summary |
| --- | --- | --- |
| `GET` | `/v1/models` | List models |
| `POST` | `/v1/systemone` | System One |

That is the complete path list. Security scheme: `HTTPBearer` (`Authorization: Bearer <API_KEY>`). Info description: “Send your API key in the Authorization header as `Bearer <API_KEY>`. Use GET /v1/models to discover available model names.”

Absent from this OpenAPI document (string search of the parsed spec): `/usage`, `/billing`, `/quota`, `/limits`, `/metrics`, `/events`, `websocket`, `wss`, `stream`, `sse` as a protocol, `graphql`, `daemon`, `X-RateLimit`, `Retry-After`, `cost`, `credit`, `spend`, `dashboard`, `console`, `analytics`. The word “usage” appears only as the **per-response** `Usage` schema on `SystemOneResponse`. “billing” appears only as an example question id. Documented response headers on both operations: **none**.

Live unauthenticated probes of the public API (2026-10-24):

| Request | Result |
| --- | --- |
| `GET https://api.typesafe.ai/v1/models` (no `Authorization`) | **403** `{"detail":{"error_type":"authentication_error","message":"Must supply an API key! Check your request and try again."}}` + `x-typesafe-request-id` |
| `GET …/v1/models` with `Authorization: Bearer dummy` | **401** `{"detail":{"error_type":"authentication_error","message":"Cannot authenticate with the server. Please check your API key and try again."}}` + `x-typesafe-request-id` |
| `POST /v1/systemone` empty body, no key | **403** same “Must supply an API key!” body |
| `GET /v1/usage`, `GET /v1/billing`, `GET /usage` | **404** `{"detail":"Not Found"}` |
| `OPTIONS /v1/systemone` | **405** `Allow: POST` |

No `X-RateLimit-*`, `Retry-After`, or usage headers on these error responses. Docs list missing/invalid key as **401**; live, a **missing** key is 403 and an **invalid** key is 401. Both carry `error_type: authentication_error`.

Paid live inference was **not** called. `.env` has `TEST_JEV_API_KEY`, not `TYPESAFE_API_KEY` / `TEST_API_KEY` as specified for optional live checks.

---

## Per-request usage fields

Official and present.

OpenAPI `components.schemas.Usage`:

- `input_tokens` (integer, required): “Number of **billable** input tokens used to evaluate the request.”
- `output_tokens` (integer, required): “Number of output tokens used to answer the questions. **Output tokens are currently free of charge.**”

`SystemOneResponse.required`: `["model", "answers", "usage"]`. Examples use `{ "input_tokens": 120, "output_tokens": 12 }`.

JS SDK (`node_modules/@typesafe-ai/sdk/dist/index.d.mts` and [docs Usage interface](https://docs.typesafe.ai/sdk/javascript/api/interfaces/Usage.md)):

```ts
interface Usage {
  readonly input_tokens: number | null;
  readonly output_tokens: number | null;
}
interface SystemOneResult<Q> {
  readonly model: string;
  readonly answers: …;
  readonly usage: Usage;
}
```

Python SDK ([responses.md](https://docs.typesafe.ai/sdk/python/api/types/responses.md), [__init__.py](https://raw.githubusercontent.com/typesafe-ai/typesafe-sdk-python/main/src/typesafe_sdk/__init__.py)): `typesafe_sdk.Usage` with `input_tokens: int | None`, `output_tokens: int | None`. Exported. No `cost`, `cached_tokens`, or spend field.

Quick start example: `"usage": { "input_tokens": 428, "output_tokens": 73 }`.

Models.md: convert tokens to dollars with **$0.042 / Mtok input**; output is free. There is no `usage.cost` field — cost is derived.

n8n first-party node ([typesafe-ai/n8n-nodes-typesafe-ai](https://github.com/typesafe-ai/n8n-nodes-typesafe-ai)): Evaluate writes `usage` onto the item only when **Simplify** is off. Still per-request, not org totals.

A GitHub issue on the JS SDK ([typesafe-ai/typesafe-sdk-js#10](https://github.com/typesafe-ai/typesafe-sdk-js/issues/10), 2026-09) asks for `cached_tokens` on `Usage` and states that today Usage is only `input_tokens` / `output_tokens` (v0.6.0). That is a feature request, not a shipped field.

---

## WebSocket / live daemon: evidence for or against

**Against, in every public source checked:**

- OpenAPI 0.2.0: no websocket, no `wss`, no SSE, no streaming operation. Inference is one JSON POST.
- JS SDK source tree (`typesafe-ai/typesafe-sdk-js`, recursive git tree): HTTP `GET`/`POST` only via `TypeSafeClient` / `Models.list`. No `WebSocket`, `EventSource`, or `wss` in installed `dist/index.mjs` / `index.d.mts`.
- Python SDK public exports: `system_one` + `models.list` + `Usage` on the response. No streaming client.
- Login JS chunks (~1.2 MiB): **zero** `wss://` literals; **zero** `EventSource`; `WebSocket` hits are Next.js App Router internals (`webSocket:` props on the RSC runtime), not a product socket; no GraphQL, no socket.io, no Ably/Pusher/Convex.
- `OPTIONS /api/usage` allows **GET, HEAD, OPTIONS** only — not a WebSocket resource.
- `Upgrade: websocket` against `/api/usage` and `/api/ws` returned **HTTP 503** `upstream connect error or disconnect/reset before headers` from Envoy, **not** `101 Switching Protocols`. That is failure of an unsupported upgrade, not a live daemon.
- Public GitHub org `typesafe-ai` (12 repos): skills, both SDKs, n8n node, public examples, WorkflowEvals, daggerverse, forks (vllm, LLaDA, pulumi-clickhouse). **No console frontend repo.** GitHub code search for websocket in `typesafe-ai/skills` returned no files. GitHub Search API for `org:typesafe-ai websocket` required auth and was not used.
- Help Center / docs: no daemon, no live usage stream.

**Ambiguous, not evidence of a usage socket:**

- Console CSP `connect-src 'self' https: wss:;` permits WSS. That can cover Stytch, PostHog, Stripe, or future features. No `wss://` URL was found in the login bundles.
- Stytch telemetry is **HTTPS** (`https://auth.typesafe.ai/submit`, `https://login.typesafe.ai/telemetry.js`), not WSS, in the inlined config.

**Conclusion from these sources:** there is no documented usage websocket, and none was observed. That does not prove an authenticated console page never opens a socket after login (those chunks were not loaded). It does prove the public API and SDKs have none, and the unauthenticated usage REST resource is HTTP GET, not WS/SSE.

---

## Auth model

| Surface | Credential | Source |
| --- | --- | --- |
| Public API `api.typesafe.ai` | `Authorization: Bearer <API_KEY>` (`TYPESAFE_API_KEY` in SDKs) | OpenAPI `HTTPBearer`; quick start; MCA §2.4 “API key (in the case of the API)” |
| Console `console.typesafe.ai` including `/usage` and `GET /api/usage` | Stytch (email / Google) + HttpOnly cookies `session`, `session_id`, `organization_id`; Cloudflare Turnstile; Next.js server actions on `/login` | Login HTML runtime config; 307 to `/login`; 401 on `/api/usage` without session; MCA §2.4 “username and password (in the case of the Web Interface)” |
| Clerk | **Not used** in observed console frontend | `clerk.typesafe.ai` NXDOMAIN; no `clerk` in login JS |
| Stripe | Publishable key in console runtime config for **Billing** checkout | `__APP_RUNTIME_CONFIG__.STRIPE_PUBLISHABLE_KEY`; Help Center Add funds |

API keys and console sessions are **not interchangeable** on the probes above: a Bearer token is what `api.typesafe.ai` wants; `console.typesafe.ai/api/usage` wants a session.

---

## Practical programmatic options (official → unofficial)

1. **Official, supported: sum per-response `usage`.** Every successful `POST /v1/systemone` returns required `usage.input_tokens` and `usage.output_tokens`. Log them. Spend ≈ `input_tokens / 1e6 * 0.042` USD at the published Jev 1.14/1.13 price (models.md). Output tokens are free. This reconstructs **your process’s** token/spend totals, not the org-wide console Usage page (other keys, playground, other services are invisible). SDKs already type this (`SystemOneResult.usage` / `typesafe_sdk.Usage`).

2. **Official, reactive: handle 429 / 529 / (Help Center) 402.** Rate-limit remaining is not a queryable gauge. On 429, back off; honor `Retry-After` / `retry-after-ms` when present (errors.md, Help Center, SDK `RateLimitError.retryAfterMs`). Org numeric limits live in the developer console (models.md). Insufficient credits are a Help Center **402**, not in OpenAPI’s error table; JS `APIError.fromResponse` has no 402 subclass (would fall through to generic `APIError`). Current credit **balance** is “view in Customer’s account” (MCA §8.2) / Settings → Billing.

3. **Official, human: console UI.** `/usage` (session), Settings → Billing (credits, history, auto top-up), developer console for current RPS/TPS. That is what TypeSafe documents.

4. **Exists internally, not a public product: poll `GET https://console.typesafe.ai/api/usage` with a console session cookie.** Undocumented. 401 problem+json without a session. OPTIONS GET/HEAD/OPTIONS. Not in OpenAPI. Not in SDKs. A dummy API key does not work. Using it would be reverse-engineering a private Web Interface API; MCA §2.4 designates username/password for the Web Interface and an API key for the API; AUP §3.2 forbids unauthorized means (scraping/crawling). **Not recommended, not official, 200 body unknown.**

5. **Not official: scrape `https://console.typesafe.ai/usage`.** Session-gated, Turnstile on login, AUP §3.2/§3.3. Do not.

6. **Does not exist in public sources: websocket / SSE / live daemon for usage.** Closest official “live” signal is still per-request `usage` on each inference response plus 429 headers when you hit the limiter.

---

## Open questions / what could not be verified

- **200 body of `GET /api/usage`.** Session required; not fetched. Whether it returns time series, request history, spend, token totals, or something else is unknown. Query params (`range`, `from`) were not rejected at the unauthenticated layer, which does not prove they are valid.
- **Whether the logged-in Usage page uses that REST GET, React Query polling, RSC, or also a WSS.** Login bundles do not include the `/usage` route chunk. Playwright was Cloudflare-blocked, so the authenticated network waterfall was not captured.
- **Whether a live inference 200/429 includes `X-RateLimit-*` or `Retry-After`.** OpenAPI documents no response headers. Unauthenticated 401/403 responses had `x-typesafe-request-id` only. A billable call was skipped (no `TYPESAFE_API_KEY` / `TEST_API_KEY` as specified; `.env` has `TEST_JEV_API_KEY` instead).
- **402 on the live API.** Help Center describes it; errors.md and OpenAPI omit it. Not reproduced here.
- **Numeric default RPS/TPS.** Docs say they are in the developer console, not in models.md.
- **Internal services behind Envoy** besides `devsite-frontend`. `GET /api/usage` and `GET /api/api-keys` share problem+json; `/api/me` does not. There may be more private routes not guessed.
- **GitHub code search** across the whole org for `websocket` required a GitHub token (API 401). Public repo file trees of both SDKs were enumerated instead.
- **Regional API hosts** on the status page (`api.us-east-1.typesafe.ai`, etc.) were not separately OpenAPI-fetched; they are listed as the same TypeSafe API.

Prior local note `notes/x402-typesafe-proxy.md` distinguished TypeSafe Help Center 402 (credits) from the x402 protocol. Re-checked: Help Center 402 is still credits; public errors.md still has no 402; OpenAPI still has no 402 / PAYMENT headers. That is independent of the Usage-page question.
