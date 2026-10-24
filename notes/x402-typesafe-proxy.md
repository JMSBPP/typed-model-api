# REF

- coinbase/x402 README (typical flow; repo is now a development fork of x402-foundation): https://github.com/coinbase/x402 — raw: https://raw.githubusercontent.com/coinbase/x402/main/README.md
- x402 Protocol Specification v2 (coinbase/x402 `main`): https://github.com/coinbase/x402/blob/main/specs/x402-specification-v2.md — raw: https://raw.githubusercontent.com/coinbase/x402/main/specs/x402-specification-v2.md
- x402 HTTP transport v2 (x402-foundation): https://github.com/x402-foundation/x402/blob/main/specs/transports-v2/http.md — raw: https://raw.githubusercontent.com/x402-foundation/x402/main/specs/transports-v2/http.md
- Same HTTP transport on the coinbase fork: https://raw.githubusercontent.com/coinbase/x402/main/specs/transports-v2/http.md
- x402 FAQ: https://docs.x402.org/faq
- docs.x402.org catalog: https://docs.x402.org/llms.txt
- Quickstart for Buyers: https://docs.x402.org/getting-started/quickstart-for-buyers.md
- Quickstart for Sellers: https://docs.x402.org/getting-started/quickstart-for-sellers.md
- Facilitator role: https://docs.x402.org/core-concepts/facilitator.md
- Facilitators directory: https://docs.x402.org/dev-tools/facilitators.md
- Wallet: https://docs.x402.org/core-concepts/wallet.md
- HTTP 402 / PAYMENT-* headers: https://docs.x402.org/core-concepts/http-402.md
- Payment schemes overview: https://docs.x402.org/schemes/overview.md
- Upto scheme: https://docs.x402.org/schemes/upto.md
- Batch settlement: https://docs.x402.org/schemes/batch-settlement.md
- Bazaar (discovery): https://docs.x402.org/extensions/bazaar.md
- CDP Bazaar list (queried): https://api.cdp.coinbase.com/platform/v2/x402/discovery/resources
- PayAI Bazaar list (queried): https://facilitator.payai.network/discovery/resources
- TypeSafe request rules and errors: https://docs.typesafe.ai/api/errors.md
- TypeSafe models (price, rate limits): https://docs.typesafe.ai/models.md
- TypeSafe Help Center 402 / credits: https://help.typesafe.ai/articles/5505198974-what-s-a-402-error-and-how-can-i-add-more-credits
- TypeSafe OpenAPI 3.1: https://api.typesafe.ai/openapi.json
- TypeSafe System One API: https://docs.typesafe.ai/api/system-one.md
- TypeSafe quick start (Bearer key): https://docs.typesafe.ai/introduction/quickstart.md
- TypeSafe legal index: https://docs.typesafe.ai/legal.md
- TypeSafe Master Customer Agreement (2026-09-23): https://typesafe.ai/legal/mca
- TypeSafe Acceptable Use Policy (2026-09-23): https://typesafe.ai/legal/acceptable-use-policy
- Installed TypeSafe JS SDK declarations: `node_modules/@typesafe-ai/sdk/dist/index.d.mts` (`fromResponse` in `index.mjs`)
- Third-party demo (Baking Bad x402.jev homepage): https://jev.agents.bakingbad.dev/
- Third-party demo skill: https://jev.agents.bakingbad.dev/SKILL.md
- Third-party demo OpenAPI: https://jev.agents.bakingbad.dev/openapi.json

# MAIN

**Short answer:** TypeSafe’s official API is prepaid credits + `Authorization: Bearer <API_KEY>`. Its public error table and OpenAPI do not document x402. HTTP 402 in TypeSafe Help Center means **insufficient credits**, not an x402 challenge. Path 1 is using someone else’s x402 seller (the only one found in this research is Baking Bad’s third-party demo at `https://jev.agents.bakingbad.dev/`). The caller needs a crypto wallet with the listed asset on a supported chain and an x402 client; they do **not** need a TypeSafe API key, TypeSafe Billing, or their own facilitator. Path 2 is running that proxy yourself: TypeSafe account + credited API key, an HTTP resource server that speaks x402 (`402` + `PAYMENT-REQUIRED` / verify / forward / settle / `PAYMENT-RESPONSE`), a facilitator (public, self-hosted, or in-process), and a `payTo` wallet. **You do not need to reach out to card issuers or bank providers for the x402 hop.** Fiat on/off-ramps are not native to x402. You *may* already use a card inside TypeSafe console Billing to keep the upstream key funded. MCA §2.3(a) forbids making TypeSafe’s Services available as a standalone service; a thin re-export of `/v1/systemone` is in that neighborhood — get counsel / TypeSafe, do not treat this note as permission.

### Direct answer (card / bank)

**No, you do not need to reach out to card or bank providers to run the x402 hop.** x402 settlement is onchain (ERC-20 / SPL / other listed assets) via a facilitator or self-facilitation. The protocol FAQ states fiat off-ramps and credit-card deposits are **not native**. You need a crypto wallet, a facilitator (or local verify/settle), and — for Path 2 — a TypeSafe API key with credits. You *may* already use a card/payment method inside TypeSafe Billing to keep that key funded; that is TypeSafe’s prepaid-credit checkout, not Visa/Mastercard/ACH onboarding for x402. Buyers may buy USDC off-protocol (exchange, card on-ramp) before paying. You do not need to become a card acquirer, implement PCI-DSS for the 402 hop, or form a bank partnership for x402 itself. Those are simply not part of the protocol.

# 1. Two different 402s

## TypeSafe official 402 = credits, not x402

Help Center article “What’s a 402 error?” (TypeSafe): a 402 “usually means there are not enough credits available for the request.” Fix: console → organization → Settings → Billing → Available credits → **Add funds**, “select or add a payment method,” follow payment prompts. If Billing is not visible, contact support. This is **not** documented as an x402 `PAYMENT-REQUIRED` challenge.

TypeSafe errors doc lists `400`, `401`, `413`, `415`, `422`, `429`, `529` — **not** `402`. `401` is “Missing or invalid API key. Check the `Authorization` header.”

Official OpenAPI (`https://api.typesafe.ai/openapi.json`, title TypeSafe 0.2.0): `servers[0].url` is `https://api.typesafe.ai`; info description: “Send your API key in the Authorization header as `Bearer <API_KEY>`.” Security scheme is `HTTPBearer`. `POST /v1/systemone` documents responses `200`, `400`, `422` only. The JSON contains **zero** occurrences of `402`, `PAYMENT`, or `x402`.

Installed JS SDK `APIError.fromResponse` maps 400, 401, 403, 404, 422, 429, and ≥500. There is **no** 402 class. A 402 would fall through to generic `APIError`.

Quick start and System One API: `POST https://api.typesafe.ai/v1/systemone` with `Authorization: Bearer <API_KEY>` and `Content-Type: application/json`. Get a key from the TypeSafe console.

Models: Jev 1.14 / 1.13 price **$42 / Btok = $0.042 / Mtok** input; output tokens free. Rate limits are per organization in the developer console; over limit → `429`. Higher limits: custom/enterprise, `sales@typesafe.ai`. Long context is an extra header (`TypeSafe-Danger-Zone-Long-Context: true`), not a payment protocol.

docs.typesafe.ai search for x402 / `PAYMENT-SIGNATURE` / `PAYMENT-REQUIRED` did not surface an official x402 product. **TypeSafe themselves do not offer x402 on the API they publish.**

## x402 402 = onchain payment challenge

x402 FAQ: “x402 is an open‑source protocol that turns the dormant HTTP `402 Payment Required` status code into a fully‑featured, onchain payment layer.” It is not a CDP-only product; Apache-2.0; “you don’t need any Coinbase products to use it.”

coinbase/x402 README (typical flow) and spec v2 + HTTP transport: unpaid request → `402` with base64 `PaymentRequired` in **`PAYMENT-REQUIRED`** → client signs and retries with **`PAYMENT-SIGNATURE`** → resource server verifies (local or facilitator `POST /verify`) → does the work → settles (chain or facilitator `POST /settle`) → `200` with **`PAYMENT-RESPONSE`**. Spec §6.1 default flow for `authorization` is verify → resource → settle → respond.

HTTP transport header table (foundation spec and coinbase fork; docs.x402.org HTTP 402 page):

| Header | Direction | Payload |
| --- | --- | --- |
| `PAYMENT-REQUIRED` | Server → Client | Base64 `PaymentRequired` JSON |
| `PAYMENT-SIGNATURE` | Client → Server | Base64 `PaymentPayload` JSON |
| `PAYMENT-RESPONSE` | Server → Client | Base64 `SettlementResponse` JSON |

`payTo` is the recipient wallet (CAIP-2 `network`, token `asset`, atomic `amount`). Example networks in FAQ / seller quickstart: Base `eip155:8453`, Base Sepolia `eip155:84532`, Solana `solana:5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp`, Solana Devnet `solana:EtWTRABZaYq6iMfeYKouRu166VU2xqa1`. FAQ table: those four are fee-free at the facilitator layer for “any ERC-20” / “any SPL”; gas is onchain.

FAQ “Why not just use API keys?”: API keys require UI account setup, **payment methods**, and plugging keys into agents. x402 is meant to remove that for the *buyer*.

FAQ “Does x402 support fiat off‑ramps or credit‑card deposits?”: **“Not natively.** However, facilitators or third‑party gateways can wrap x402 flows with on‑ and off‑ramps.”

# 2. Path 1 — call an existing x402 seller (no TypeSafe key)

## Who exists

**TypeSafe first-party:** none found. Official API is Bearer keys only (OpenAPI, errors, quick start).

**Third-party, found:** Baking Bad **x402.jev** at `https://jev.agents.bakingbad.dev/`. Homepage: “Experimental access to TypeSafe’s Jev System One model through Baking Bad’s paid service.” “No API key, no subscription — an agent pays for each call over x402 or MPP.” “This is a demo, not a product” — “not intended or permitted for production use.” “Neither TypeSafe nor Baking Bad accepts responsibility or liability.” Evaluation data “is forwarded through Baking Bad to TypeSafe.” Agents must read `/SKILL.md` and get explicit user confirmation before calling.

OpenAPI `info.externalDocs`: “Official TypeSafe HTTP API; this service replaces caller API-key authentication with x402/MPP and applies its own demo-use and error policies.” SKILL.md: TypeSafe `401`/`529` are mapped to opaque `503`; “Do not ask the user for a TypeSafe API key to resolve it.” The **seller holds the upstream TypeSafe key**.

**Bazaar / facilitator catalogs (this research):** CDP `GET https://api.cdp.coinbase.com/platform/v2/x402/discovery/resources` reported `pagination.total` **41048**. First 200 items (offset 0 and 100) contained **no** `typesafe.ai`, `jev.agents`, or `bakingbad`. `?q=jev` did not change the listing (param appears ignored). PayAI `GET https://facilitator.payai.network/discovery/resources` first page (100 items) also had none of those strings. `https://x402.org/facilitator/discovery/resources` returned **404**. This is not a full scan of 41k CDP rows; no first-party TypeSafe seller appeared in the sampled catalogs, and TypeSafe’s own docs do not list one.

## What the Path 1 caller needs

From x402 buyer quickstart + FAQ + Baking Bad (third-party):

1. **A crypto wallet** with the asset the 402 `accepts` names (buyer quickstart: “A crypto wallet with USDC (any EVM or SVM compatible wallet)”). FAQ: agents need wallets; they sign locally. Baking Bad live challenge is authoritative for scheme/network/asset/`payTo`/amount.
2. **An x402 client** that handles 402 → sign → retry. Buyer quickstart: `@x402/fetch` (`wrapFetchWithPayment`) or `@x402/axios`, plus scheme packages (`@x402/evm`, `@x402/svm`, …). Register the scheme the seller advertises (`exact`, `upto`, `batch-settlement`).
3. **No TypeSafe API key.** Baking Bad homepage and OpenAPI say so; SKILL.md forbids asking for one.

## What the Path 1 caller does **not** need

- TypeSafe console account, Billing, or card/bank onboarding with TypeSafe (x402 FAQ: the point of x402 vs API keys; Baking Bad replaces caller API-key auth).
- Their own facilitator (buyer talks only to the resource server; the **seller** calls `/verify` and `/settle`).
- Becoming a card acquirer.

## Limits (Baking Bad, third-party claims)

- **Demo vs production:** homepage + SKILL.md + OpenAPI: experimental, as-is, **not permitted for production**, no consequential real-world decisions. Contact `hello@bakingbad.dev`.
- **Who holds the TypeSafe key:** Baking Bad’s upstream account (SKILL.md “models available through the service’s upstream account”).
- **Data:** “evaluation data is forwarded through Baking Bad to TypeSafe”; “synthetic or non-sensitive demo data only.” TypeSafe then processes Input under the **seller’s** TypeSafe account (MCA §4.1 Input includes End User materials the Customer submits).
- **Pricing vs TypeSafe $0.042/Mtok:** TypeSafe list price is $0.042 per million **input** tokens (models.md). Baking Bad prices **per evaluation** from a token estimate of the parsed body + question count, clamped to a published USD range **$0.00001 – $0.002957** (`x-payment-info` on `/v1/systemone`). Discovery `accepts` amounts are metadata; “the live `402` challenge for your exact body carries the authoritative amount.” Floors: Etherlink & batch `$0.00001`; other rails `$0.0002`. SKILL.md: Base facilitator refuses below `0.001` USD (`amount_too_low`), so ordinary bodies should use Etherlink `exact` or Base `batch-settlement`, not Base `exact`. Do not treat the demo range as TypeSafe’s list price, and do not assume a published markup — they did not publish one.
- **Rails they advertise (discovery, live 402 wins):** x402 Etherlink `eip155:42793` `exact`; Base `eip155:8453` `batch-settlement` and `exact`; Solana mainnet `exact`; plus MPP Tempo (not x402). EVM `payTo` in OpenAPI discovery: `0x26e80e1d98d89E933f2D31955E719D19d214E779`. Solana `payTo`: `4SHMcqadX3DViKFermsfRSzGVSF7XLMpZWyJanK1PWKX`. Base asset in that document is `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913` (USDC on Base, as they list it).
- **Body:** unpaid POST then retry with **unchanged** method/URL/body and `PAYMENT-SIGNATURE` (SKILL.md; matches x402 typical flow).
- **Size:** demo body limit 1 MiB (SKILL.md) vs TypeSafe 32 MiB (errors.md). Context: they cite TypeSafe’s 64k/32k Jev limits.

# 3. Path 2 — run your own proxy (requirements checklist)

You become the x402 **resource server** (seller). Buyers pay *you* onchain; *you* call TypeSafe with **your** Bearer key.

## 1. TypeSafe account + API key **with credits**

- Console API key (quick start). Send it only to `https://api.typesafe.ai` as `Authorization: Bearer <YOUR_KEY>` (OpenAPI, System One API). Do not give it to buyers (MCA §2.4: keep Access Credentials confidential).
- Credits: MCA §8.2 — “In order to generate Output or otherwise use the Services, Customer must obtain TypeSafe-managed credits” consumed per Input. Purchased Credits expire at end of Term or 12 months, whichever is earlier. If balance hits zero: auto-refill if opted in, else TypeSafe “may decline to generate Output.”
- Help Center: add funds in **Settings → Billing** with a **payment method**. That *is* card/bank (or whatever methods TypeSafe’s checkout offers) **with TypeSafe**, not with x402. MCA §8.1: Fees in USD, default net-30 invoices — enterprise/order terms may differ. Custom/enterprise: `sales@typesafe.ai` (models.md, legal ZDR).
- If the key is empty, TypeSafe Help Center says you get **their** 402 (credits), which is not an x402 challenge you can settle with USDC.

## 2. HTTP resource server that speaks x402, then forwards to TypeSafe

Seller quickstart prerequisites: crypto wallet to receive funds; Node/Go/Python; an existing API/server. Provide facilitator URL/client, routes to protect, receiving wallet address.

**Unpaid** `POST /v1/systemone` (or whatever path you protect): HTTP **402** + `PAYMENT-REQUIRED` (base64 `PaymentRequired`: `x402Version`, `resource`, `accepts[]` with `scheme`, `network`, `amount`, `asset`, `payTo`, `maxTimeoutSeconds`, optional `extra`). Spec §5.1; HTTP transport; seller quickstart: “When a request is made to these routes without payment, your server will respond with the HTTP 402 Payment Required code and payment instructions.”

**Paid retry:** client sends the **same** request plus `PAYMENT-SIGNATURE`. Server:

1. **Verify** locally or `POST {facilitator}/verify` with `{ x402Version, paymentPayload, paymentRequirements }` (spec §7.1; README steps 5–6). Default `authorization` flow: verify **before** doing the work.
2. If invalid → 402 again (README step 7).
3. If valid → **forward the request body** to `https://api.typesafe.ai/v1/systemone` with `Authorization: Bearer <YOUR_KEY>` and `Content-Type: application/json` (TypeSafe quick start). Optional TypeSafe headers (e.g. long-context) are TypeSafe’s, not x402’s. Keep the buyer’s System One JSON; do not require a caller TypeSafe key.
4. **Settle** by chain or `POST {facilitator}/settle` (same body shape as `/verify`; spec §7.2). For `upto`, `amount` at settle is the **actual** charge, not the authorized max.
5. Return **200** + resource body + `PAYMENT-RESPONSE` (base64 `SettlementResponse`: `success`, `transaction`, `network`, `payer`) (HTTP transport; README step 12). Failed settlement: 402 + `PAYMENT-RESPONSE` with `success: false`.

Middleware exists (`@x402/express`, `@x402/hono`, `@x402/fastify`, `@x402/next`, Go gin/echo, Python FastAPI/Flask) so you do not have to hand-roll headers; you still must implement the TypeSafe forward as *your* handler.

Browser CORS: HTTP transport says `PAYMENT-*` are not CORS-safelisted; expose/allow them if browsers will call you. Not required for agent/curl clients.

## 3. A facilitator — not a card network

Facilitator docs: optional but recommended; verifies payloads and settles onchain so the seller need not run chain nodes. “The facilitator does not hold funds or act as a custodian.” Spec §7: resource servers may “delegate blockchain operations to trusted third parties **or host the endpoints themselves**.”

Three paths (facilitator docs + README “Choosing a Production Path” + facilitators directory):

| Goal | Path |
| --- | --- |
| Testnet / quickstart | Public `https://x402.org/facilitator` (Base Sepolia + Solana devnet). **Not** for mainnet. |
| Managed production | A production facilitator that supports your network |
| Full control | Run your own facilitator, or **self-facilitate** inside the resource server |

FAQ “Who runs facilitators today?”: “Multiple organizations operate production facilitators. The protocol is permissionless—anyone can run a facilitator.” Directory (selected, not exhaustive; fetched 2026-10-24): Built on Stellar; **CDP Facilitator** (Coinbase-hosted, KYT/OFAC; seller quickstart example URL `https://api.cdp.coinbase.com/platform/v2/x402`); Celo (`https://api.x402.celo.org` / sepolia); Corbits; Dexter; Fireblocks; FTP Canton; HPP; Meridian; Mogami; NEAR x402; **PayAI** (`https://facilitator.payai.network` in seller quickstart); Polygon; Solvador; Sui (UIG Studios); T54 XRPL; X Pay (merchant API key required); TRDEFI Arc. You **choose or run one**; you do not contract with Visa/Mastercard for this role.

Some facilitators add KYT (CDP). FAQ troubleshooting: address “flagged by KYT” can keep returning 402. That is facilitator policy, still not a card network.

You do **not** need a facilitator API from a bank. Testnet x402.org facilitator “requires no setup.”

## 4. A `payTo` wallet

Seller quickstart: “A crypto wallet to receive funds (any EVM or SVM compatible wallet).” Route config `payTo` is that address. Mainnet: “real mainnet address where you want to receive USDC payments.” Wallet docs: sellers receive USDC/crypto; address is in payment requirements.

`network` is CAIP-2 (`eip155:8453` for Base, etc.). `asset` is the token contract (or ISO 4217 if a fiat scheme existed; FAQ: fiat is not native). Buyer pays that asset to `payTo`.

You need enough gas **on the facilitator’s** settlement path as implemented; FAQ: many facilitators are fee-free but “Gas paid onchain”; mainnet wallets need USDC (and sometimes native gas depending on ATM). Buyer quickstart funds the **buyer** wallet; seller receives.

## 5. Scheme choice: `exact` vs `upto` vs `batch-settlement`

From schemes overview, seller quickstart, FAQ, spec §6:

- **`exact`**: buyer authorizes **exactly** the advertised amount; FAQ troubleshooting: strict equality, no over/underpay. Simplest; all supported networks in the seller table. Good for a flat per-call price. Default examples.
- **`upto`**: buyer authorizes a **maximum**; seller settles actual usage (tokens, compute, bandwidth). FAQ: available on EVM in TS/Go/Python; seller quickstart: EVM Permit2 in TS/Go/Python, Solana in TS/Go. Server calls `setSettlementOverrides` with actual amount. Natural fit for TypeSafe **input-token** billing ($0.042/Mtok) if you quote a cap then settle `usage.input_tokens`.
- **`batch-settlement`**: buyer deposits into escrow once, signs off-chain vouchers per request; seller claims onchain in batches. Still a per-request maximum; can use the same override pattern. FAQ: TS and Go today; Python planned. Docs page: also SVM. Needs channel storage + channel manager (claim/settle/refund intervals). Baking Bad uses this on Base because per-tx floor is high relative to a tiny Jev call.

`auth-capture` exists (escrow hold/capture/void) but is not required for a TypeSafe proxy.

Default payment flow is `authorization` (verify → work → settle). `upto` and `batch-settlement` support `authorization` only (schemes overview).

## 6. Card / bank providers (required answer)

**x402 hop:** native protocol does **not** require contacting Visa, Mastercard, card issuers, ACH, or a bank partner. Settlement is onchain token transfer (spec `/settle`; FAQ networks table). Fiat on/off-ramps are **not native** (FAQ). Facilitators are verifiers/settlers, not card acquirers.

**Buyer USDC:** the buyer’s problem. They fund a wallet however they like (exchange, third-party on-ramp). That is off-protocol.

**Your TypeSafe key:** keeping credits loaded **does** go through TypeSafe Billing (Help Center payment method) or MCA purchased credits / invoiced Fees / sales. That is ordinary TypeSafe checkout, already true if you call TypeSafe directly. It is not x402 merchant onboarding.

**Off-ramp of received USDC:** optional, third-party, not required to run the proxy. FAQ: facilitators or third-party gateways *can* wrap off-ramps; they are not part of the protocol.

**What you do not need for the 402 hop:** card-acquirer status; PCI-DSS as an x402 protocol requirement (docs never mention PCI or card data, because there is no card PAN on the wire); a bank partnership to accept 402 payments.

## 7. Legal / ops

MCA §2.1: license is **non-exclusive, non-transferable, non-sublicensable** — access Services per Documentation, and integrate the API into **Customer Applications**.

MCA §2.2: Customer Application = software “developed and operated by Customer **for the benefit of Customer’s end users**,” including the API.

MCA §2.3(a): Customer will not “sell, lease, loan, distribute, sublicense, disclose, or otherwise offer or make the Services available **as a standalone service**.” Also (b) no distillation / competing model; (k) no access other than as permitted; (l) AUP.

A Path 2 service that is essentially “TypeSafe `/v1/systemone`, paid with x402 instead of a TypeSafe key” is the thing §2.3(a) names. Embedding Jev inside *your* product for *your* End Users is what §2.2 names. **This note does not decide which bucket you are in.** Baking Bad’s own demo disclaims production use and names both TypeSafe and Baking Bad as not liable — that is not a TypeSafe grant of resale rights.

MCA §2.4: Access Credentials (API key) stay confidential; Customer is responsible for actions through the key. Forwarding End User Input: Customer is responsible for Input and End User acts (MCA §5); TypeSafe processes that Input as Customer Data (§4.1).

AUP §3.2: do not “access the Services through unauthorized means (e.g., scraping or crawling).” Calling `api.typesafe.ai` with your own key is the designated API mechanism (MCA §2.4), not scraping. AUP does not mention x402.

Baking Bad (third-party): production use not permitted.

Ops: you eat TypeSafe `429`/`529`/credit 402; you still owe the buyer a 402/500/503 policy. Rate limits are **your** org’s (models.md). You pay TypeSafe $0.042/Mtok regardless of what you charge in USDC.

## 8. What you do **not** need (Path 2)

- Card-network onboarding, PCI-DSS for x402, bank partnership for the 402 hop (protocol docs: onchain + facilitator).
- Buyer TypeSafe keys.
- Coinbase account (FAQ: x402 is not a CDP product; CDP facilitator is one option).
- The public x402.org facilitator on mainnet (explicitly the wrong choice).
- Fiat off-ramp to start receiving USDC.

# 4. Mapping Path 2 onto TypeSafe’s wire format

Buyer → your proxy:

- `POST /v1/systemone` JSON body as in TypeSafe System One (`state`, `model`, `questions`).
- No `Authorization: Bearer` from the buyer (that is *your* secret).
- x402: unpaid → 402 + `PAYMENT-REQUIRED`; paid → `PAYMENT-SIGNATURE`.

Your proxy → TypeSafe:

- `POST https://api.typesafe.ai/v1/systemone`
- `Authorization: Bearer <YOUR_KEY>`
- `Content-Type: application/json`
- Same body (plus any TypeSafe-only headers you choose to pass through).

Do not send `PAYMENT-*` headers to TypeSafe; they are not in TypeSafe’s OpenAPI and are not an auth method there.

# 5. Unresolved / not guessed

- Whether MCA §2.3(a) forbids a given Path 2 deployment: quote is above; no TypeSafe FAQ on x402 resale was found. Ask TypeSafe/sales/counsel.
- Exact TypeSafe checkout rails (which card brands, ACH, invoices-only) beyond Help Center “payment method” and MCA USD Fees/Credits.
- Full CDP Bazaar (41k items): only 200 listed + a no-op `q=` query. No TypeSafe official seller in TypeSafe docs.
- Baking Bad production SLA, markup, or key custody beyond their demo pages.
- Facilitator contract terms / KYC for a specific production facilitator (CDP advertises KYT/OFAC; others say “no account required” — read that operator’s docs before relying).
