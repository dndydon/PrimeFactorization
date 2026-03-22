# Migration Guide: v2.0 to v3.0

## Date: March 21, 2026

This document describes the v3.0 API consolidation that unified duplicate implementations behind the `PrimeFactorizable` protocol.

## Quick Reference

| v2.0 | v3.0 |
|------|------|
| `n.fastPrimeFactors` | `n.primeFactors` |
| `try await primeFactors(of: n)` | `n.primeFactors` |
| `try await primeFactorsOptimized(of: n)` | `n.primeFactors` |
| `allFactors(of: n)` | `n.allFactors` |
| `PrimeFactorizationSyncConfig.shared` | `PrimeFactorizationConfig.shared` |
| `await PrimeFactorizationConfig.maxPrimeRange` | `PrimeFactorizationConfig.shared.maxPrimeRange` |
| `PrimeIteratorSequence(from: a, through: b)` | `try primeNumbers(from: a, through: b)` |

## Detailed Changes

### 1. `fastPrimeFactors` renamed to `primeFactors`

The optimizations from `fastPrimeFactors` (`trailingZeroBitCount`, `reserveCapacity`, branch-optimized loops) are now built into `primeFactors`. There is no longer a separate "fast" variant.

**Before:**
```swift
let factors = 60.fastPrimeFactors
```

**After:**
```swift
let factors = 60.primeFactors
```

### 2. Async free functions removed

The sync `.primeFactors` property is fast enough for all practical inputs (even `Int.max` factors in under a second). The async wrappers added overhead without benefit.

**Before:**
```swift
let factors = try await primeFactors(of: 5040)
let optimized = try await primeFactorsOptimized(of: 987654321)
```

**After:**
```swift
let factors = 5040.primeFactors
let optimized = 987654321.primeFactors
```

For batch processing, `primeFactorsConcurrent(of:)` is still available:
```swift
let results = try await primeFactorsConcurrent(of: [12, 18, 24])
```

### 3. `allFactors(of:)` is now a property

**Before:**
```swift
let factors = allFactors(of: 60)
```

**After:**
```swift
let factors = 60.allFactors
```

This also works on `Int64` and `UInt`:
```swift
let factors = Int64(60).allFactors
```

### 4. Configuration simplified

The actor-based `PrimeFactorizationConfig` and lock-based `PrimeFactorizationSyncConfig` have been merged into a single `PrimeFactorizationConfig` class.

**Before:**
```swift
PrimeFactorizationSyncConfig.shared.maxPrimeRange = 50_000_000
// or
await PrimeFactorizationConfig.setMaxPrimeRange(50_000_000)
```

**After:**
```swift
PrimeFactorizationConfig.shared.maxPrimeRange = 50_000_000
```

### 5. `PrimeIteratorSequence` removed

It pre-computed all primes in its initializer, providing no memory advantage over `primeNumbers(from:through:)`.

**Before:**
```swift
for prime in PrimeIteratorSequence(from: 100, through: 200) {
    print(prime)
}
```

**After:**
```swift
for prime in try primeNumbers(from: 100, through: 200) {
    print(prime)
}
```

### 6. Generic type support

`Int64` and `UInt` now have `primeFactors`, `isPrime`, and `allFactors` through the `PrimeFactorizable` protocol:

```swift
Int64(600_000_000_004).primeFactors  // [2, 2, 3, 50000000001]
UInt(97).isPrime                      // true
Int64(60).allFactors                  // [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60]
```

## Unchanged APIs

These work exactly as before:
- `n.primeFactors` (on `Int`)
- `n.isPrime` (on `Int`)
- `n.largestPrimeFactor`
- `n.smallestPrimeFactor`
- `primeNumbers(from:through:)`
- `primeFactorsConcurrent(of:)`
- `PrimeGenerator` actor
- `PrimeFactorizationError`
- `[Int].simpleArrayDescription`
- `[Int].primeFactorizationString`
