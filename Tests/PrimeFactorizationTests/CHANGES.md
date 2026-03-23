# PrimeFactorization Package - Change History

## v3.1 - Small Primes Table (March 22, 2026)

### Overview
Added a pre-computed table of the first 1,000 primes (2 through 7,919) to accelerate trial division in `Int.primeFactors` and `Int.isPrime`. The table covers complete factorization for numbers up to ~62.7 million without needing the 6k±1 fallback, and skips ~40% of composite candidates that the 6k±1 method would otherwise test.

### Added
- `SmallPrimes.swift` -- static array of 1,000 primes, compiled into the binary (no file I/O)
- `smallPrimesTable_correctness` test -- verifies every entry is prime with no gaps
- `intPrimeFactors_tableBoundary` test -- verifies correct behavior at the table/6k±1 handoff

### Changed
- `Int.primeFactors` now iterates through the small primes table before falling back to 6k±1
- `Int.isPrime` now checks divisibility against the table before falling back to 6k±1
- `PrimeGenerator.primes(upTo:)` returns a slice of the table instantly for limits <= 7,919

---

## v3.0 - API Consolidation (March 21, 2026)

### Overview
Consolidated ~60 public symbols into ~20 focused symbols. Unified duplicate implementations behind the `PrimeFactorizable` protocol.

### Added
- `PrimeFactorizable` protocol with generic `primeFactors`, `isPrime`, and `allFactors`
- `Int`-specific optimized overrides using `trailingZeroBitCount` and `multipliedReportingOverflow`
- `PrimeFactorizable.allFactors` property (replaces `allFactors(of:)` free function)
- `PrimeFactorizable` conformances for `Int`, `Int64`, `UInt`

### Changed
- `PrimeFactorizationSyncConfig` renamed to `PrimeFactorizationConfig`
- `Int.primeFactors` now uses optimizations from former `fastPrimeFactors`
- `Int.isPrime` uses integer-only arithmetic (removed `Double.squareRoot()`)
- `primeFactorsConcurrent(of:)` moved to `PrimeGenerator.swift`, uses sync `.primeFactors` internally
- `startCursor(from:)` made private
- `primesByJump6Method(from:through:)` made private

### Removed
- `Int.fastPrimeFactors` (folded into `Int.primeFactors`)
- `primeFactors(of:) async throws` (sync version is fast enough)
- `primeFactorsOptimized(of:) async throws` (duplicate)
- `PrimeIteratorSequence` (pre-computed, no advantage over `primeNumbers()`)
- `PrimeFactorizationConfig` actor (redundant with sync config)
- `View.primeFactorization(of:)` SwiftUI modifier (incomplete stub)
- `doubleValue` protocol requirement

### File Changes
- New: `PrimeFactorizable.swift` (protocol + conformances + Int overrides)
- New: `PrimeGenerator.swift` (actor + concurrent batch)
- Rewritten: `PrimeFactorization.swift` (simplified, 174 lines from 617)
- Updated: `PrimeFactorizationDemo.swift`
- Deleted: `generic_prime_implementation.swift`
- Updated: All 3 test files (49 tests, all passing)

---

## v2.0 - Namespace Consolidation (March 16, 2026)

### Overview
Resolved namespace conflicts by merging `PrimeFactorization2.swift` and `PrimeFactorizationExtensions.swift` into the main source files.

### Added
- Async functions: `primeFactors(of:)`, `primeFactorsOptimized(of:)`, `primeFactorsConcurrent(of:)`
- Array extensions: `simpleArrayDescription`, `primeFactorizationString`
- `generic_prime_implementation.swift` with `PrimeFactorizable` protocol
- `PrimeGenerator` actor with caching and Sieve of Eratosthenes

### Changed
- Unified `PrimeFactorizationError` enum (removed duplicate definitions)
- `largestPrimeFactor` / `smallestPrimeFactor` return `Int?` instead of `Int`

### Removed
- `PrimeFactorization2.swift`
- `PrimeFactorizationExtensions.swift`
- Thread-unsafe global prime cache
- Dead code (`BrokenPrimeIterator2Sequence`, commented-out structs)

---

## v1.0 - Initial Implementation

- Prime factorization using 6k+/-1 trial division
- Primality testing
- Prime generation
- `PrimeIteratorSequence`
- `allFactors(of:)` utility
