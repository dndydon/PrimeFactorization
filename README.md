# PrimeFactorization Package

A Swift package providing optimized prime factorization, primality testing, and prime generation with generic type support. Works with `Int`, `Int64`, `UInt`, and any `FixedWidthInteger` conforming type.

## Revision History

| Version | Date year-mon-day | Changes |
|---------|------|---------|
| **v3.3** | 2026-09-23 | Shared 64-bit engine for `Int`, `Int64`, `UInt`: Miller-Rabin and Pollard-Brent rho above 7,927² (`Int.max` factors in ~0.1 ms instead of ~38 ms; `Int.max.allFactors` in µs instead of 49 s). `allFactors` built from prime factors and made a protocol requirement. Odd-only segmented sieve, also used by `PrimeGenerator.primes(upTo:)`. Fixed `primeNumbers` skipping a 6k+1 start value. Tests reorganized into 7 files mirroring the sources (debug run: 21.7 s to 1.3 s). See `CHANGES.md`. |
| v3.2 | 2026-09-22 | Generic code on `Int` now uses the optimized overrides (`primeFactors`/`isPrime` are protocol requirements). `PrimeGenerator.primes(upTo:)` sieves off the actor. `primeNumbers(from:through:)` uses a segmented sieve (15M range: 38 s to 1.6 s). `PrimeGenerator` cache evicts oldest entry (FIFO) instead of clearing everything. |
| v3.1 | 2026-03-22 | Pre-computed table of 1,000 small primes for faster trial division |
| v3.0 | 2026-03-21 | API consolidation: unified `PrimeFactorizable` protocol, removed duplicates, optimized `Int` overrides (see `MIGRATION.md`) |
| v2.0 | 2026-03-16 | Namespace conflict resolution, async API consolidation |
| v1.0 | — | Initial implementation |

## Features

### Core Protocol: `PrimeFactorizable`

All prime operations are available on any conforming type (`Int`, `Int64`, `UInt`):

- **`.primeFactors`**: `[Self]` - Prime factors in ascending order
- **`.isPrime`**: `Bool` - Primality check (deterministic Miller-Rabin above ~62.8 million)
- **`.allFactors`**: `[Self]` - All divisors in ascending order

### Int Conveniences

- **`.largestPrimeFactor`**: `Int?` - Largest prime factor, or `nil` for values <= 1
- **`.smallestPrimeFactor`**: `Int?` - Smallest prime factor, or `nil` for values <= 1

### Prime Generation

- **`primeNumbers(from:through:) throws -> [Int]`** - Generate primes in a range using a segmented sieve (6k+/-1 trial division for narrow ranges of very large numbers)

### Async Operations

- **`primeFactorsConcurrent(of:) async throws -> [Int: [Int]]`** - Concurrent batch factorization
- **`PrimeGenerator`** - Actor with cached factorization (FIFO eviction at 10,000 entries) and Sieve of Eratosthenes (runs off the actor)

### Formatting

- **`[Int].simpleArrayDescription`**: `String` - Format as "[2, 2, 3, 5]"
- **`[Int].primeFactorizationString`**: `String` - Format as "2^2 x 3 x 5"

### Configuration

- **`PrimeFactorizationConfig.shared.maxPrimeRange`** - Thread-safe max range for prime generation (default: 15,000,000)

## Usage

### Basic Operations (Any PrimeFactorizable Type)

```swift
import PrimeFactorization

// Works on Int
60.primeFactors        // [2, 2, 3, 5]
17.isPrime             // true
60.allFactors          // [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60]

// Works on Int64
Int64(600_000_000_004).primeFactors  // [2, 2, 3, 50000000001]

// Works on UInt
UInt(97).isPrime       // true
```

### Prime Factor Utilities

```swift
60.largestPrimeFactor   // Optional(5)
60.smallestPrimeFactor  // Optional(2)
1.largestPrimeFactor    // nil
```

### Prime Generation

```swift
let primes = try primeNumbers(from: 10, through: 30)
// [11, 13, 17, 19, 23, 29]
```

### Concurrent Batch Factorization

```swift
let numbers = [12, 18, 24, 30]
let results = try await primeFactorsConcurrent(of: numbers)
// [12: [2, 2, 3], 18: [2, 3, 3], 24: [2, 2, 2, 3], 30: [2, 3, 5]]
```

### PrimeGenerator (Cached + Sieve)

```swift
let generator = PrimeGenerator()

// Cached factorization -- fast for repeated lookups
let factors = await generator.primeFactors(of: 5040)
// [2, 2, 2, 2, 3, 3, 5, 7]

// Sieve of Eratosthenes -- efficient for generating all primes up to N
let primes = await generator.primes(upTo: 1000)
// 168 primes from 2 to 997
```

### Formatted Output

```swift
let factors = [2, 2, 3, 3, 3, 5]
factors.simpleArrayDescription    // "[2, 2, 3, 3, 3, 5]"
factors.primeFactorizationString  // "2^2 x 3^3 x 5"
```

## Performance

- `Int`, `Int64`, and `UInt` share one 64-bit engine:
  - Trial division with a pre-computed table of 1,000 small primes (2 through 7,919) fully handles values below 7,927² (~62.8 million)
  - Above that, deterministic Miller-Rabin tests primality and Pollard-Brent rho splits composites, so 19-digit values factor in about a millisecond
  - `trailingZeroBitCount` for fast power-of-2 extraction
- `allFactors` is built from the prime factorization, so `Int.max.allFactors` takes microseconds instead of ~50 seconds
- `primeFactors`, `isPrime`, and `allFactors` are protocol requirements, so generic code calling them on `Int`, `Int64`, or `UInt` uses the engine
- Other conforming types fall back to generic 6k+/-1 trial division with `multipliedReportingOverflow` for overflow-safe arithmetic
- `primeNumbers(from:through:)` uses an odd-only segmented sieve with bounded memory (2...15M: ~12 ms release); narrow ranges of huge values use trial division with Miller-Rabin
- `PrimeGenerator.primes(upTo:)` returns instantly from the table for limits <= 7,919, and uses the segmented sieve above that

## Error Handling

```swift
public enum PrimeFactorizationError: Error, Equatable {
    case invalidInput(String)
    case rangeTooLarge(Int)
}
```

## File Organization

| File | Contents |
|------|----------|
| `PrimeFactorizable.swift` | Protocol, conformances, generic defaults, Int overrides |
| `PrimeFactorization.swift` | Error, config, utilities, prime generation |
| `PrimeGenerator.swift` | Actor (caching + sieve), concurrent batch factorization |
| `SmallPrimes.swift` | Pre-computed table of first 1,000 primes |
| `PrimeFactorizationDemo.swift` | Demo functions |

## Requirements

- Swift 6.0+
- Async features require macOS 10.15+ / iOS 13.0+
- No external dependencies

## License

MIT License. Copyright (c) 2024-2026 Don Sleeter
