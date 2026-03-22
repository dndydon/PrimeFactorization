# PrimeFactorization v3.0 - API Consolidation

## Date: March 21, 2026

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

- `Int.primeFactors` now incorporates all optimizations from the former `fastPrimeFactors`: `trailingZeroBitCount` for fast factor-2 extraction, `reserveCapacity(32)`, and branch-optimized `if/repeat-while` loops
- `Int.isPrime` uses integer-only arithmetic (removed `Double.squareRoot()` dependency)
- Both use `multipliedReportingOverflow` for overflow-safe loop bounds
- `startCursor(from:)` made private (was leaked as internal)

## File Organization

| File | Lines | Contents |
|------|-------|----------|
| `PrimeFactorizable.swift` | 236 | Protocol, conformances, generic defaults, Int overrides |
| `PrimeFactorization.swift` | 174 | Error, config, utilities, prime generation |
| `PrimeGenerator.swift` | 114 | Actor (caching + sieve), `primeFactorsConcurrent` |
| `PrimeFactorizationDemo.swift` | 134 | Demo functions |

Total source: ~658 lines (down from ~978)

## Test Results

49 tests: 49 passed, 0 failed

## Version History

- **v1.0** - Initial implementation
- **v2.0** - Namespace conflict resolution, async API consolidation
- **v3.0** - API consolidation: unified protocol, removed duplicates, optimized Int overrides
