# REF

- Pack catalog: https://github.com/stefan-hoeck/idris2-pack-db/blob/main/STATUS.md
- Pack HEAD collection: https://github.com/stefan-hoeck/idris2-pack-db/blob/main/collections/HEAD.toml
- Pack-db README (catalog vs nightly CI): https://github.com/stefan-hoeck/idris2-pack-db/blob/main/README.md
- Idris 2 wiki third-party list: https://github.com/idris-lang/Idris2/wiki/Third-party-Libraries
- Idris 2 `contrib.ipkg` (`System.Random`): https://github.com/idris-lang/Idris2/blob/main/libs/contrib/contrib.ipkg
- Idris 2 `System.Random`: https://github.com/idris-lang/Idris2/blob/main/libs/contrib/System/Random.idr
- Idris 2 Chez `blodwen-random`: https://github.com/idris-lang/Idris2/blob/main/support/chez/support.ss
- Idris 2 Racket `blodwen-random`: https://github.com/idris-lang/Idris2/blob/main/support/racket/support.rkt
- Idris 2 CHANGELOG (`System.Random` added to contrib): https://github.com/idris-lang/Idris2/blob/main/CHANGELOG.md
- Idris 2 `prelude.ipkg`: https://github.com/idris-lang/Idris2/blob/main/libs/prelude/prelude.ipkg
- Idris 2 `base.ipkg`: https://github.com/idris-lang/Idris2/blob/main/libs/base/base.ipkg
- Idris 2 `linear.ipkg`: https://github.com/idris-lang/Idris2/blob/main/libs/linear/linear.ipkg
- Pure PRNG (SplitMix): https://github.com/buzden/idris2-random-pure
- Summary statistics / `Probability`: https://github.com/buzden/idris2-summary-stat
- Hedgehog (test RNG, not a stats lib): https://github.com/stefan-hoeck/idris2-hedgehog
- GSL distribution FFI: https://github.com/idris-bayes/distribution
- Probabilistic programming: https://github.com/idris-bayes/monad-bayes
- Log-domain numerics: https://github.com/idris-bayes/log-domain
- Free monads (PPL support): https://github.com/idris-bayes/free
- ProbFX port (commented out of HEAD.toml): https://github.com/idris-bayes/prob-fx
- idris-bayes org: https://github.com/idris-bayes
- TLS crypto RNG: https://github.com/idris-community/idris2-tls
- TensorType finite distributions: https://github.com/bgavran/TensorType
- Spidr Gaussians / GP / Bayesian optimisation: https://codeberg.org/joelberkeley/spidr
- DepTyCheck (PBT, not stats): https://github.com/buzden/deptycheck
- Idris1 probability (not Idris 2): https://github.com/fieldstrength/probability
- Wiki `missing-numeric`: https://github.com/seagull-kamome/idris2-missing-numeric
- TypeSafe intro (typed answers + probabilities): https://docs.typesafe.ai/introduction
- TypeSafe primitives: https://docs.typesafe.ai/primitives.md
- TypeSafe confidence vs probability: https://docs.typesafe.ai/confidence.md
- TypeSafe OpenAPI answers: https://docs.typesafe.ai/go/api.md

# MAIN

**Short answer:** Idris 2 **does** have libraries in all four buckets, but they are uneven. (a) **RNG/PRNG:** compiler `contrib` `System.Random` (IO `Int32`/`Double`, **not** crypto) plus pack `random-pure` (pure SplitMix). (b) **Distributions + sampling:** pack `distribution` is a **GSL C FFI** (normal, poisson, binomial, … sample/PDF/inverse CDF); pack `summary-stat` types a `[0,1]` `Probability` and computes normal CDF / erf / binomial Wilson intervals — it does **not** sample. (c) **Stochastic processes:** no SDE library; the closest Markov artefact is `monad-bayes`'s HMM **example**, plus pack `spidr`'s Gaussian-process model. (d) **PPL / Bayesian inference:** pack `monad-bayes` (experimental Haskell port: SMC, trace MH, PMMH, RMSMC, SMC2). `hedgehog` is a **property-test generator** that happens to use `random-pure`; it is not a stats library. Wiki Data science lists `spidr` and codegen, **not** probability; `monad-bayes` is under Misc.

For this project (native Idris 2, `pack.toml`, TypeSafe structured answers that **already include** `probabilities` / `confidence`): do **not** add GSL/`monad-bayes`. Type the API's `[0,1]` fields; optionally use pack `summary-stat`'s `Probability` as the Idris wrapper. Sampling and inference are the model's job, not the client's.

# PACK-DB: what exists

Searched `collections/HEAD.toml` and `STATUS.md` for `probability`, `probabilistic`, `stochastic`, `random`, `rng`, `distribution`, `dist`, `gaussian`, `normal`, `poisson`, `markov`, `mcmc`, `measure`, `stats`, `statistics`, `bayes`, `bayesian`, `sampling`, `monte-carlo`, `prng`, `xoroshiro`, `mersenne`, `hedgehog`. Hits below. **No `probability`, `stochastic`, `rng`, `gaussian`, `poisson`, `markov`, `mcmc`, `measure`, `stats`, `statistics`, `bayes`, `sampling`, `monte-carlo`, `prng`, `xoroshiro`, or `mersenne` package names appear in HEAD.toml.** Closest keys: `random-pure`, `distribution`, `summary-stat`, `monad-bayes`, `log-domain`, `free`, `hedgehog`, `tensortype`, `spidr`. `prob-fx` exists on GitHub and is **commented out** of HEAD.toml.

## In pack-db (canonical catalog)

| Pack name | Repo | STATUS.md description | Category | Tests col. |
| --- | --- | --- | --- | --- |
| `random-pure` | https://github.com/buzden/idris2-random-pure | "Pure pseudo-random interface and splitmix implementation" | (a) PRNG | success |
| `distribution` | https://github.com/idris-bayes/distribution | "An FFI for statistical distributions from the GSL C library." | (b) sample/PDF via GSL | empty |
| `summary-stat` | https://github.com/buzden/idris2-summary-stat | "Facilities for summary statistics" | (b) `Probability` type + normal CDF/CI; **no sampling** | success |
| `monad-bayes` | https://github.com/idris-bayes/monad-bayes | "A probabilistic language with emphasis on compositional inference, based on the original Haskell library" | (d) PPL; HMM example is (c) | empty |
| `log-domain` | https://github.com/idris-bayes/log-domain | "A small representation of numerical computations in the log domain." | (d) support | empty |
| `free` | https://github.com/idris-bayes/free | "An encoding of free monads and free monad transformers" | (d) support | empty |
| `hedgehog` | https://github.com/stefan-hoeck/idris2-hedgehog | "A property based testing library with integrated shrinking" | (a) **test** RNG only | success |
| `bounded-doubles-hedgehog-generators` | https://github.com/buzden/idris2-bounded-doubles | "Hedgehog generators for bounded doubles" | test gens | success |
| `evince-hedgehog` | https://github.com/bio-aeon/evince | "Hedgehog property testing bridge for evince" | test bridge | success |
| `tensortype` | https://github.com/bgavran/TensorType | "Type-safe pure functional tensor processing framework, supporting non-cubical tensors" | (b) finite logit `Dist` + IO sample | empty |
| `spidr` | https://codeberg.org/joelberkeley/spidr | "Hardware-accelerated machine learning with dependent types." | (b) Gaussian pdf/cdf; (c) GP; (d) Bayes opt | empty |
| `tls` | https://github.com/idris-community/idris2-tls | (bundled as `tls`) | (a) **crypto** RNG for TLS | (see STATUS `tls` row) |
| `deptycheck` | https://github.com/buzden/deptycheck | "Property-based testing with dependent types" | test gens, not stats | empty |
| `idrisGL` | https://github.com/ECburx/Idris2GL | (empty brief in STATUS) | (a) graphics `randomInt`; **not** stats | empty |
| `algebra` | https://github.com/stefan-hoeck/idris2-algebra | "Lawful algebraic structures" | groups/rings, **not** measure theory | empty |

HEAD.toml entries (pack names are the install names):

```toml
[db.random-pure]
type   = "git"
url    = "https://github.com/buzden/idris2-random-pure"
commit = "master"
ipkg   = "random-pure.ipkg"

[db.distribution]
type   = "github"
url    = "https://github.com/idris-bayes/distribution"
commit = "main"
ipkg   = "distribution.ipkg"

[db.summary-stat]
type   = "github"
url    = "https://github.com/buzden/idris2-summary-stat"
commit = "master"
ipkg   = "summary-stat.ipkg"

[db.monad-bayes]
type   = "github"
url    = "https://github.com/idris-bayes/monad-bayes"
commit = "main"
ipkg   = "monad-bayes.ipkg"

[db.log-domain]
type   = "github"
url    = "https://github.com/idris-bayes/log-domain"
commit = "main"
ipkg   = "log-domain.ipkg"

[db.free]
type   = "github"
url    = "https://github.com/idris-bayes/free"
commit = "main"
ipkg   = "free.ipkg"

[db.hedgehog]
type   = "github"
url    = "https://github.com/stefan-hoeck/idris2-hedgehog"
commit = "main"
ipkg   = "hedgehog.ipkg"
```

Sources: https://github.com/stefan-hoeck/idris2-pack-db/blob/main/collections/HEAD.toml and https://github.com/stefan-hoeck/idris2-pack-db/blob/main/STATUS.md

Commented out (not in the catalog):

```toml
# [db.prob-fx]
# type   = "github"
# url    = "https://github.com/idris-bayes/prob-fx"
# commit = "main"
# ipkg   = "prob-fx.ipkg"
```

Source: https://github.com/stefan-hoeck/idris2-pack-db/blob/main/collections/HEAD.toml

`prob-fx` README: "An experimental port of the Haskell library [prob-fx](https://github.com/min-nguyen/prob-fx) for probabilistic programming to Idris2." Source: https://github.com/idris-bayes/prob-fx/blob/main/README.md

Empty STATUS.md **Tests** cells mean the nightly table did not record `success` for that package; they are still in HEAD.toml. Source: STATUS.md table vs pack-db README ("You can see the current package list plus the build status of all packages [here](STATUS.md)").

## Not in pack-db / wiki-only / wrong language

| Package | Repo | Why it is not the catalog answer |
| --- | --- | --- |
| `prob-fx` | https://github.com/idris-bayes/prob-fx | Experimental PPL port. **Commented out** of HEAD.toml. |
| `melocule` | https://github.com/idris-bayes/melocule | Org page: "Probabilistic music composition in Idris2". Not a HEAD.toml key. |
| `missing-numeric` | https://github.com/seagull-kamome/idris2-missing-numeric | Wiki Misc: "some math data types". `missing-numeric.ipkg` modules are `Data.Rational`, `Data.Fixed`, `Data.Complex` — **no** Probability/Random. Not in HEAD.toml. |
| `probability` (Idris 1) | https://github.com/fieldstrength/probability | README: "Needs Idris 0.9.19 or the current Github version." Idris **1**, not Idris 2, not pack-db. |
| Idris2GL `IdrisGL.Random` | https://github.com/ECburx/Idris2GL | Pack `idrisGL` exists, but the module documents itself as "unsafe, predictable" graphics RNG. |

Wiki **Data science** lists python backends, jupyter, json-schema, data-frame, odf, **spidr**. Wiki **Testing** lists `hedgehog`. Wiki **Misc.** lists `monad-bayes` ("Probabilistic programming, port from the haskell library of the same name") and `missing-numeric`. No Markov/SDE/measure section. Source: https://github.com/idris-lang/Idris2/wiki/Third-party-Libraries

idris-bayes org blurb: "Probabilistic programming for Idris2". Public repos include `monad-bayes`, `distribution`, `prob-fx`, `free`, `melocule`. Source: https://github.com/idris-bayes

# IDRIS 2 ITSELF: IO Random, no Data.Random, not crypto

The compiler ships these libraries under `libs/`: `prelude`, `base`, `contrib`, `linear`, `network`, `papers`, `test`. There is **no** `Data.Random` module. Random lives in **`contrib`**, not `prelude`/`base`. Source: https://github.com/idris-lang/Idris2/tree/main/libs and `contrib.ipkg` (`System.Random` in the modules list). CHANGELOG: "New modules in `contrib` for JSON (`Language.JSON.*`); random numbers (`System.Random`)". Later: "`System.Random` support for `Int` changed to `Int32`"; JS backends supported. Sources: https://github.com/idris-lang/Idris2/blob/main/libs/contrib/contrib.ipkg and https://github.com/idris-lang/Idris2/blob/main/CHANGELOG.md

`prelude.ipkg` / `base.ipkg` / `linear.ipkg` list no Random module. Sources: those ipkg files.

## `System.Random`: `HasIO` → `Int32` / `Double`, finite, not crypto

```idris
public export
interface Random a where
  randomIO : HasIO io => io a

  ||| Takes a range (lo, hi), and returns a random value uniformly
  ||| distributed in the closed interval [lo, hi]. It is unspecified what
  ||| happens if lo > hi.
  randomRIO : HasIO io => (a, a) -> io a
```

Instances:

- `Random Int32`: `randomIO` over `[-2^31, 2^31-1]`; `randomRIO (lo, hi)` maps `prim__randomBits32` into that closed interval.
- `Random Double`: `randomIO` in `[0, 1]`; `randomRIO` scales to `[lo, hi]`.

FFI:

```idris
%foreign "scheme:blodwen-random"
         "javascript:lambda:(max)=>Math.floor(Math.random() * max)"
prim__randomBits32 : Bits32 -> PrimIO Bits32

%foreign "scheme:blodwen-random"
         "javascript:lambda:()=>Math.random()"
prim__randomDouble : PrimIO Double

%foreign "scheme:blodwen-random-seed"
prim__srand : Bits64 -> PrimIO ()
```

Helpers: `rndFin : HasIO io => (n : Nat) -> io (Fin (S n))`, `rndSelect'` on a non-empty `Vect`, `rndSelect` on a `NonEmpty` list. Source: https://github.com/idris-lang/Idris2/blob/main/libs/contrib/System/Random.idr

Chez backend (`blodwen-random`): no-arg form is `(random 1.0)` i.e. `[0, 1.0)`; one-arg `k` is `(random k)` i.e. integral `[0, k)`. Seed via Chez `random-seed`. Source: https://github.com/idris-lang/Idris2/blob/main/support/chez/support.ss

Racket: `(random)` / `(random k)` plus `random-seed`. Source: https://github.com/idris-lang/Idris2/blob/main/support/racket/support.rkt

This is a **finite, seedable, non-crypto PRNG** wrapping the host `random` / `Math.random`. The TLS library says so in first-party text: "The base Idris library has `System.Random`, but it is not cryptographically random". Source: https://github.com/idris-community/idris2-tls/blob/master/README.md

There is **no** compiler module for Gaussian/Poisson/Markov/measure.

# HOW TYPING WORKS IN EACH LIBRARY

## 1. (a) Pure PRNG: `random-pure` (buzden) — SplitMix `StdGen`

`random-pure.ipkg` brief: "Pure pseudo-random interface and splitmix implementation". Modules: `Control.Monad.Random`, `System.Random.Pure`, `System.Random.Pure.StdGen`. Source: https://github.com/buzden/idris2-random-pure/blob/master/random-pure.ipkg

README (primary):

> `RandomGen g` describes a data type `g` which can be used as a seed and an algorithm of producing pseudo-random data and the next seed (`next` function). Also, it allows to split a seed to two independent seeds using the `split` function.
>
> This library contains one implementation of `RandomGen` named `StdGen` using the SplitMix algorithm.

Source: https://github.com/buzden/idris2-random-pure/blob/master/README.md

Practical API:

```idris
interface RandomGen g where
  next    : g -> (g, Bits64)
  split   : g -> (g, g)
  variant : Nat -> g -> g

interface Random a where
  randomR : RandomGen g => (a, a) -> g -> (g, a)
  random  : RandomGen g => g -> (g, a)

initStdGen : HasIO io => io StdGen
mkStdGen : Bits64 -> StdGen

evalRandomIO : HasIO io => RandomT io a -> io a
getRandom  : MonadRandom m => Random a => m a
getRandomR : MonadRandom m => Random a => (a, a) -> m a
```

`Random` instances include `Bits64`, `Int32`/`Int64`, `Double` (mantissa from `Bits64`, ULP `1/2^53`), `Fin (S n)`, `Bool`, `Nat`, `Integer`. `Double` `random` is **not** a named statistical distribution; it is uniform-ish bits→`[0,1)`. Sources: https://github.com/buzden/idris2-random-pure/blob/master/src/System/Random/Pure.idr and https://github.com/buzden/idris2-random-pure/blob/master/src/System/Random/Pure/StdGen.idr

`initStdGen` xors `clockTime UTC` nanoseconds, `time`, and `getPID` — OS entropy to seed SplitMix, **not** a CSPRNG. Source: StdGen.idr

In-tree `tests/distribution/*` check that generated **integers/bools/doubles** look uniform. That is RNG quality testing, not a distributions library.

## 2. (a) Crypto RNG: `tls` `Crypto.Random` — bytes, not distributions

`MonadRandom` here is **byte** entropy for TLS, not `randomIO : io Double`:

```idris
interface Monad m => MonadRandom (0 m : Type -> Type) where
  random_bytes : (n : Nat) -> m (Vect n Bits8)
```

C backend: `getrandom` (Linux), `BCryptGenRandom` (Windows), `arc4random_buf` (else). JS: Node `crypto.randomBytes` / `crypto.getRandomValues`. Also a ChaCha12 DRG. README: bindings exist "in order to provide cryptographically secure random entropy". Sources: https://github.com/idris-community/idris2-tls/blob/master/src/Crypto/Random.idr, https://github.com/idris-community/idris2-tls/blob/master/src/Crypto/Random/C.idr, https://github.com/idris-community/idris2-tls/blob/master/support/idristls.c, README.md

Use this for keys/nonces, **not** for Gaussian sampling or TypeSafe probabilities.

## 3. (a) Test RNG: `hedgehog` — `Gen a = Size -> StdGen -> Cotree a`

README: "An Idris port of the Haskell Hedgehog library, a property-based testing library in the spirit of QuickCheck." Feature: "Monadic random value generators with integrated shrinking." It **depends on** `random-pure` **and** `summary-stat`. Sources: https://github.com/stefan-hoeck/idris2-hedgehog/blob/main/README.md and https://github.com/stefan-hoeck/idris2-hedgehog/blob/main/hedgehog.ipkg

```idris
record Gen (a : Type) where
  constructor MkGen
  unGen   : Size -> StdGen -> Cotree a
```

Source: https://github.com/stefan-hoeck/idris2-hedgehog/blob/main/src/Hedgehog/Internal/Gen.idr

Hedgehog **imports** `Statistics.Probability` to turn a test `Confidence` into a Wilson interval via `wilsonBounds` (coverage checks). That is test-coverage statistics, not a user-facing dist library. Source: https://github.com/stefan-hoeck/idris2-hedgehog/blob/main/src/Hedgehog/Internal/Property.idr

**Say so:** hedgehog is a test RNG + shrinker. Do not depend on it for model probabilities.

`deptycheck` is the same category: "property-based testing with dependent types and automatic derivation of generators". Source: https://github.com/buzden/deptycheck/blob/master/README.md

`idrisGL` `randomInt`: "This function is only for users who want to easily render random picture elements. Please don't use it for precise calculations." Source: https://github.com/ECburx/Idris2GL/blob/main/src/IdrisGL/Random.idr

`evince` `Evince.Random` is a Numerical Recipes LCG used to shuffle lists. Source: https://github.com/bio-aeon/evince/blob/master/evince/src/Evince/Random.idr

## 4. (b) GSL distributions: pack `distribution`

`distribution.ipkg` brief: "An FFI for statistical distributions from the GSL C library." `prebuild` compiles `lib/distribution.c` with `$(gsl-config --libs)`. Modules: Uniform, Normal, Binomial, Beta, Gamma, Geometric, Hypergeometric, Poisson, Dirichlet, GSL. Depends on `contrib`. Source: https://github.com/idris-bayes/distribution/blob/main/distribution.ipkg

README: requires GSL (`sudo apt-get install libgsl-dev`). Source: https://github.com/idris-bayes/distribution/blob/main/README.md

RNG seed is a C pointer to `gsl_rng_default` after `gsl_rng_env_setup()` (GSL's default type / `GSL_RNG_TYPE`, not an Idris PRNG):

```c
gsl_rng* init_gsl_rng() {
  gsl_rng* r;
  gsl_rng_env_setup();
  const gsl_rng_type * T;
  T = gsl_rng_default;
  r = gsl_rng_alloc (T);
  return r;
}
```

Source: https://github.com/idris-bayes/distribution/blob/main/lib/distribution.c

Practical API (Normal; others match this shape):

```idris
gsl_normal : (mu : Double) -> (std : Double) -> GslRng -> IO Double
gsl_normal_pdf : (mu : Double) -> (std : Double) -> (obs : Double) -> Double
gsl_normal_cdf_inv : (mu : Double) -> (std : Double) -> (r : Double) -> Double
```

Poisson: `gsl_poisson : (mu : Double) -> GslRng -> IO Nat` + PDF. Binomial: `gsl_binomial : (n : Nat) -> (p : Double) -> GslRng -> IO Nat`. Uniform: `gsl_uniform : min -> max -> GslRng -> IO Double`. Dirichlet returns `Vect (S n) Double`. Sources: `Statistics/Distribution/{Normal,Poisson,Binomial,Uniform,Dirichlet}.idr`

The umbrella module re-exports those and contains a commented test calling `normal`, `binomial`, `uniform`, `dirichlet`. Source: https://github.com/idris-bayes/distribution/blob/main/Statistics/Distribution.idr

This is **IO sampling + PDF/inverse-CDF over unrefined `Double`/`Nat`**. No Idris proof that `p ∈ [0,1]`. Native C dependency (libgsl). STATUS.md Tests column empty.

## 5. (b) Typed `[0,1]` + normal CDF, no sampling: `summary-stat`

README:

> This library contains:
> - a data definition for *probability*,
> - definitions around *error function* and CDF of the normal distribution, and
> - some definitions for calculating *confidence interval* for binomial distribution.

Source: https://github.com/buzden/idris2-summary-stat/blob/master/README.md

```idris
data Probability : Type where
  P : DoubleBetween 0 1 -> Probability

fromDouble : (x : Double) -> (0 _ : So $ 0 <= x && x <= 1) => Probability
maybeP : Double -> Maybe Probability
ratio : (num, den : Nat) -> (0 _ : num `LTE` den) => (0 _ : IsSucc den) => Probability
(.percent) : DoubleBetween 0 100 -> Probability
(*) : Probability -> Probability -> Probability
inv : Probability -> Probability
```

Source: https://github.com/buzden/idris2-summary-stat/blob/master/src/Statistics/Probability.idr

Normal:

```idris
interface NormCDF where
  normcdf : SolidDouble -> Probability

interface InvNormCDF where
  invnormcdf : Probability -> SolidDouble
```

`erf` / `erfc` FFI to libm `erfc`. Wilson score interval:

```idris
wilsonBounds :
  InvNormCDF =>
  (confidence : Probability) ->
  (count : Nat) ->
  (0 _ : IsSucc count) =>
  (successes : Probability) ->
  (Probability, Probability)
```

Sources: https://github.com/buzden/idris2-summary-stat/blob/master/src/Statistics/Norm.idr, Erf.idr, Confidence.idr

**No** `sample`, **no** Gaussian/Poisson *random variate*, **no** Markov. Closest catalog type for a TypeSafe probability in `[0,1]`.

## 6. (d) PPL: `monad-bayes` (+ `log-domain` + `free` + `distribution`)

README: "An experimental Idris2 translation of the Haskell library [monad-bayes](https://github.com/tweag/monad-bayes) for probabilistic programming." Source: https://github.com/idris-bayes/monad-bayes/blob/main/README.md

`monad-bayes.ipkg` depends on `contrib, free, distribution, log-domain`. Modules include `Control.Monad.Bayes.Interface`, `Sampler`, `Weighted`, `Population`, `Sequential`, `Traced.{Basic,Dynamic,Static}`, `Inference.{SMC,RMSMC,PMMH,SMC2}`. Source: https://github.com/idris-bayes/monad-bayes/blob/main/monad-bayes.ipkg

```idris
interface Monad m => MonadSample m where
  ||| Draws a random value from Uniform(0,1)
  random : m Double
  uniform : (min, max : Double) -> m Double
  normal : (mean, sd : Double) -> m Double
  gamma, beta : (a, b : Double) -> m Double
  bernoulli : (p : Double) -> m Bool
  binomial : (n : Nat) -> (p : Double) -> m Nat
  categorical : {n : Nat} -> Vect n Double -> m (Fin n)
  poisson : (p : Double) -> m Nat
  -- geometric, hypergeometric, dirichlet, …

interface Monad m => MonadCond m where
  score : Log Double -> m ()

interface (MonadSample m, MonadCond m) => MonadInfer m where
```

Default sampling uses GSL inverse CDFs on `random`. `SamplerIO = IO` with `MonadSample` `random = System.Random.randomIO` (contrib, **not** crypto). `sampleIOwith m seed = srand seed >> m`. Sources: https://github.com/idris-bayes/monad-bayes/blob/main/Control/Monad/Bayes/Interface.idr and Sampler.idr

Trace MH (MCMC-family, not a standalone "Markov chains" lib):

```idris
mhStep : MonadSample m => Traced m a -> Traced m a
mh : MonadSample m => (n : Nat) -> Traced m a -> m (Vect (S n) a)
```

Source: https://github.com/idris-bayes/monad-bayes/blob/main/Control/Monad/Bayes/Traced/Basic.idr

SMC: `smcSystematic` / `smcMultinomial` take timestep and particle counts. PMMH: `pmmh n_mhsteps n_timesteps n_particles`. Sources: Inference/SMC.idr, Inference/PMMH.idr

**HMM example (the Markov-process artefact):**

```idris
transModel : MonadSample m => Double -> Nat -> m Nat
transModel transition_p x = do
  dX <- bernoulli transition_p
  pure (x + boolToNat dX)

hmm : MonadInfer m => Nat -> List Nat -> Params -> m Params
```

Drivers: `mhHMM`, `smcHMM`, `rmsmcHMM`. Source: https://github.com/idris-bayes/monad-bayes/blob/main/examples/idris2/HMM.idr

`log-domain`: `record Log (a : Type) where constructor Exp; ln : a` with log-sum-exp `Num (Log Double)`. Source: https://github.com/idris-bayes/log-domain/blob/main/Numeric/Log.idr

This stack is **local Bayesian inference** (you write a generative model and run SMC/MH). It is **not** a client for TypeSafe's returned `probabilities` object. STATUS.md Tests column empty; README says experimental. Needs **libgsl** via `distribution`.

## 7. (b)/(c)/(d) `spidr`: Gaussian tensors, GP, Bayesian optimisation

`spidr.ipkg` modules include `Spidr.Distribution`, `Spidr.Model.GaussianProcess`, `Spidr.BayesianOptimization`. Brief: "Hardware-accelerated machine learning with dependent types." AGPL-3.0-or-later. Source: https://codeberg.org/joelberkeley/spidr/src/branch/master/spidr/spidr.ipkg

```idris
interface Distribution (0 dist : (0 event : Shape) -> (0 dim : Nat) -> Type) where
  mean : dist event dim -> Tag $ Tensor (dim :: event) F64
  cov  : dist event dim -> Tag $ Tensor (dim :: dim :: event) F64

data Gaussian : (0 event : Shape) -> (0 dim : Nat) -> Type where
  MkGaussian : {d : Nat} -> (mean : Tensor (S d :: event) F64) ->
               (cov : Tensor (S d :: S d :: event) F64) ->
               Gaussian event (S d)
```

`ClosedFormDistribution` supplies `pdf` / `cdf`. **NOTE** `cdf` is implemented only for univariate `Gaussian`; multivariate `cdf` `idris_crash`es. Source: https://codeberg.org/joelberkeley/spidr/src/branch/master/spidr/src/Spidr/Distribution.idr

Gaussian process: "a collection of random variables, any finite number of which have joint Gaussian distribution" as `MkGP : MeanFunction features -> Kernel features -> GaussianProcess features`, with posterior and log-marginal-likelihood. Source: https://codeberg.org/joelberkeley/spidr/src/branch/master/spidr/src/Spidr/Model/GaussianProcess.idr

Bayesian optimisation module header: "Functionality for Bayesian optimization, the data-efficient optimization of objective functions" via a `ProbabilisticModel` and acquisition. Source: https://codeberg.org/joelberkeley/spidr/src/branch/master/spidr/src/Spidr/BayesianOptimization.idr

This is **ML / GP**, not a TypeSafe answer codec. Hardware/XLA stack, AGPL, STATUS Tests empty.

## 8. (b) `tensortype`: named-axis logit `Dist`, finite choices

```idris
record Dist (name : AxisName) (i : Nat) where
  constructor MkDist
  logits : Tensor [name ~~> i] Double

uniform : {name : AxisName} -> {i : Nat} -> (isSucc : IsSucc i) => Dist name i
diracDelta : {name : AxisName} -> {i : Nat} -> IsSucc i => (j : Fin i) -> Dist name i
```

`MonadSample m` `sample : Dist name i -> m (Fin i)`. `IO` instance: softargmax → cumulative sum → `System.Random.randomRIO (0.0, 1.0)` → bin. Also deterministic `pickMax` / `pickFirst`. Sources: https://github.com/bgavran/TensorType/blob/main/src/Control/Monad/Distribution.idr and https://github.com/bgavran/TensorType/blob/main/src/Control/Monad/Sample/Instances.idr

README: "main purpose is enabling rapid prototyping of structured neural network architectures"; early, not performant. Source: https://github.com/bgavran/TensorType/blob/main/README.md

Useful as a **finite categorical** over `Fin n` logits, not as a wrapper for TypeSafe's string-keyed `probabilities` map, and not a PPL.

# TYPESAFE (this project's probabilities)

TypeSafe is **not** an Idris library. The model **returns** probabilities; the Idris client only has to type and consume them.

Intro: "You get typed values and probability distributions that your code can branch on, sort by, and route with. Some question types also return confidence". Source: https://docs.typesafe.ai/introduction

Primitives:

| Type | Answer fields |
| --- | --- |
| Choice | `choice`, `probabilities`, `confidence` |
| Score | `score`, `legend`, `probabilities`, `confidence` |
| Noul | `noul` (0 to 1) — "The probability that the answer is yes." No separate `confidence`. |

Source: https://docs.typesafe.ai/primitives.md

OpenAPI `ChoiceAnswer.probabilities`: "Probability of each choice in criteria, keyed by choice name, from 0 to 1. … values sum to approximately 1." `confidence`: "from 0 to 1". `NoulAnswer`: "The probability of a yes answer or a true statement." Source: https://docs.typesafe.ai/go/api.md

Confidence docs: `confidence` is a **statistic of the already-returned distribution** (Choice: \((p_{\max} - 1/n)/(1 - 1/n)\); Score uses a MAD-vs-uniform formula; Noul has no `confidence`, optional \(|2p-1|\)). "Because the formulas below are exact and every answer includes its full `probabilities`, you can compute whichever measure matters most to your application instead." Source: https://docs.typesafe.ai/confidence.md

There is no Typesafe-owned Idris probability/PPL package. Do not invent one. Do not treat `monad-bayes` as the TypeSafe client.

# GAPS (evidence)

1. **No pack package named `probability` / `stats` / `markov` / `mcmc` / `measure` / `gaussian` / `poisson` / `rng` / `xoroshiro` / `mersenne`.** Absence is from searching HEAD.toml keys and STATUS.md descriptions.
2. **No compiler distributions or stochastic-process lib.** `System.Random` is IO uniform `Int32`/`Double` via host `random`/`Math.random`. No `Data.Random`. `prelude`/`base`/`linear`/`network` have no Random. Source: contrib `System/Random.idr` + ipkgs.
3. **`System.Random` is not crypto and not a named distribution.** TLS README states it is not cryptographically random. JS path is `Math.random()`. Finite 32-bit ints.
4. **No SDE library; Markov is an example, not a package.** `monad-bayes` HMM example is a Bernoulli random walk + binomial observations. No `Control.Markov` / SDE module in pack-db.
5. **GSL `distribution` is FFI, unrefined `Double`, Tests column empty, needs libgsl.** Inverse-CDF sampling is `IO`. Not a dependent-types probability monad by itself.
6. **`summary-stat` types `[0,1]` and computes CDF/CI; it does not sample and does not implement Choice-style categorical maps.**
7. **`hedgehog` / `deptycheck` / `idrisGL` / `evince` RNGs are not stats libraries.** Hedgehog's own README is QuickCheck-style PBT; it only *uses* `summary-stat` for coverage.
8. **`prob-fx` is commented out of the catalog.** idris-bayes PPL beyond `monad-bayes` is uncurated.
9. **Idris 1 `fieldstrength/probability` is the historical "Prob monad" — it is not Idris 2.**
10. **Wiki Data science has no probability section;** `monad-bayes` is Misc; `spidr` is accelerated linear algebra / ML.
11. **TypeSafe already ships `probabilities` + `confidence`.** An Idris PPL does not produce those fields; json-schema / records do.

Closest building blocks (first-party / pack-db):

- `[0,1]` wrapper: pack `summary-stat` `Statistics.Probability` (`maybeP`, `fromDouble` with `So` bounds)
- Uniform IO RNG (if ever needed): `contrib` `System.Random` (`randomIO` / `randomRIO`)
- Pure seedable RNG: pack `random-pure` (`StdGen`, SplitMix)
- Crypto bytes (TLS only): pack `tls` `Crypto.Random`
- Named dist sampling (local sim, GSL): pack `distribution`
- Local PPL (do not use for the HTTP client): pack `monad-bayes`
- Finite categorical over `Fin n`: pack `tensortype` `Control.Monad.Distribution`
- JSON body types: existing `json-schema` custom dep (this repo)

# RECOMMENDATION FOR typed-model-api

This repo is native Idris 2 (`typed-model-api.ipkg` depends on `json-schema`; HTTP research already points at pack `http`). TypeSafe answers are **already** probability distributions: Choice/Score maps in `[0,1]` plus a derived `confidence`; Noul is a single `[0,1]`. Sources: TypeSafe primitives + OpenAPI (above). The client does not need to sample, run MH, or link GSL to *get* those numbers.

**Do this:**

1. **Type the API fields.** Generate (or hand-write) answer records from TypeSafe's schema via the existing json-schema toolchain. Keep `probabilities` as a map/list of `[0,1]` numbers and `confidence` / `noul` as `[0,1]`. That is the product surface.

2. **Optional pack dep for the `[0,1]` wrapper only:** `summary-stat`. Decode with `maybeP : Double -> Maybe Probability` (reject out-of-range). Use `(.asDouble)` at the JSON boundary if `json`/`json-simple` has no `ToJSON Probability`. Do **not** pull `bounded-doubles-hedgehog-generators` into the app (test-only).

3. **If you recompute confidence** (TypeSafe already sends it): implement the formulas from https://docs.typesafe.ai/confidence.md in a few total functions over the decoded map. That is arithmetic on lists of `Probability`, not a PPL.

4. **Do not** add `distribution` / `monad-bayes` / `log-domain` / `free` unless this project starts *doing* local inference (HMM, SMC). They need GSL, are marked experimental / Tests-empty, and do not talk HTTP. **Do not** add `spidr` (AGPL ML/XLA) or `tensortype` (NN logits) to wrap TypeSafe answers. **Do not** use `hedgehog` as a probability library. **Do not** use `contrib` `System.Random` or `tls` `Crypto.Random` to fabricate TypeSafe probabilities.

5. RNG only if a later feature needs local jitter/tests: `random-pure` (`mkStdGen` / `evalRandomIO`) for reproducible tests; `System.Random` for throwaway IO; `tls` only for cryptographic bytes.

**Do not** overclaim a "typed probability stack." For TypeSafe, the type is: a record of answers whose numeric fields inhabit `[0,1]` (and whose Choice maps are keyed by the question's criteria). Sampling, Markov processes, and Bayesian inference exist in pack-db for *other* programs; they are the wrong dependency for this HTTP client.
