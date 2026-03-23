# PrimeFactorization v3.1 - API Consolidation + Small Primes Table

## Date: March 22, 2026

## Summary

Consolidated ~60 public symbols with significant overlap into ~20 focused symbols with one clear way to do each operation. The API now provides type flexibility via the `PrimeFactorizable` protocol while maintaining high performance through `Int`-specific optimized overrides.

## What Changed

### Unified Prime Operations via Protocol

Before: 3 ways to get prime factors of an `Int`, 2 `isPrime` implementations, separate `allFactors(of:)` free function.

After: One `PrimeFactorizable` protocol with generic defaults for `primeFactors`, `isPrime`, and `allFactors`. `Int` provides optimized overrides. Works on `Int`, `Int64`, and `UInt`.

### Removed Duplicate APIs

| Removed | Replacement |
|---------|-------------|
| `Int.fastPrimeFactors` | Optimizations folded into `Int.primeFactors` |
| `primeFactors(of:) async throws` | Use sync `.primeFactors` (fast enough) |
| `primeFactorsOptimized(of:) async throws` | Use sync `.primeFactors` |
| `PrimeIteratorSequence` | Use `primeNumbers(from:through:)` |
| `PrimeFactorizationConfig` actor | Renamed `PrimeFactorizationSyncConfig` to `PrimeFactorizationConfig` |
| `View.primeFactorization(of:)` | Removed (incomplete stub) |
| `allFactors(of:)` free function | Use `.allFactors` property |
| `doubleValue` protocol requirement | Removed (not needed) |

### Kept

| Symbol | Reason |
|--------|--------|
| `primeFactorsConcurrent(of:)` | Useful for batch processing multiple numbers |
| `PrimeGenerator` actor | Caching + Sieve of Eratosthenes serves distinct use cases |
| `primeNumbers(from:through:)` | Primary prime generation API |

### Performance Improvements

- `Int.primeFactors` and `Int.isPrime` use a pre-computed table of 1,000 small primes (2 through 7,919) as trial divisors, skipping composite candidates and covering complete factorization up to ~62.7 million without the 6k±1 fallback loop
- `trailingZeroBitCount` for fast factor-2 extraction, `reserveCapacity(32)`, and branch-optimized `if/repeat-while` loops
- `Int.isPrime` uses integer-only arithmetic (removed `Double.squareRoot()` dependency)
- Both fall back to 6k±1 with `multipliedReportingOverflow` for overflow-safe loop bounds beyond the table
- `PrimeGenerator.primes(upTo:)` returns a slice of the table instantly for limits <= 7,919
- `startCursor(from:)` made private (was leaked as internal)

## File Organization

| File | Lines | Contents |
|------|-------|----------|
| `PrimeFactorizable.swift` | 246 | Protocol, conformances, generic defaults, Int overrides |
| `PrimeFactorization.swift` | 174 | Error, config, utilities, prime generation |
| `PrimeGenerator.swift` | 120 | Actor (caching + sieve), `primeFactorsConcurrent` |
| `SmallPrimes.swift` | 114 | Pre-computed table of first 1,000 primes (2--7,919) |
| `PrimeFactorizationDemo.swift` | 134 | Demo functions |

## Test Results

51 tests: 51 passed, 0 failed

## Version History

- **v1.0** - Initial implementation
- **v2.0** - Namespace conflict resolution, async API consolidation
- **v3.0** - API consolidation: unified protocol, removed duplicates, optimized Int overrides
- **v3.1** - Pre-computed small primes table for faster trial division
