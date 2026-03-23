# PrimeFactorization Package

A Swift package providing optimized prime factorization, primality testing, and prime generation with generic type support. Works with `Int`, `Int64`, `UInt`, and any `FixedWidthInteger` conforming type.

Last Updated: 2026.03.22 **v3.1**

## Features

### Core Protocol: `PrimeFactorizable`

All prime operations are available on any conforming type (`Int`, `Int64`, `UInt`):

- **`.primeFactors`**: `[Self]` - Prime factors in ascending order
- **`.isPrime`**: `Bool` - Primality check (O(sqrt(n)) complexity)
- **`.allFactors`**: `[Self]` - All divisors in ascending order

### Int Conveniences

- **`.largestPrimeFactor`**: `Int?` - Largest prime factor, or `nil` for values <= 1
- **`.smallestPrimeFactor`**: `Int?` - Smallest prime factor, or `nil` for values <= 1

### Prime Generation

- **`primeNumbers(from:through:) throws -> [Int]`** - Generate primes in a range using 6k+/-1 method

### Async Operations

- **`primeFactorsConcurrent(of:) async throws -> [Int: [Int]]`** - Concurrent batch factorization
- **`PrimeGenerator`** - Actor with cached factorization and Sieve of Eratosthenes

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

- `Int` uses a pre-computed table of 1,000 small primes (2 through 7,919) for trial division, covering complete factorization up to ~62.7 million without the 6k+/-1 fallback
- `trailingZeroBitCount` for fast power-of-2 extraction
- Falls back to 6k+/-1 trial division for divisors beyond the table
- Generic types (`Int64`, `UInt`) use `multipliedReportingOverflow` for overflow-safe arithmetic
- O(sqrt(n)) complexity for factorization and primality testing
- `PrimeGenerator.primes(upTo:)` returns instantly from the table for limits <= 7,919
- In release builds, the compiler specializes generics for concrete types, closing the performance gap

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
