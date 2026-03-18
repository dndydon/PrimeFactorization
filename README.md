#  PrimeFactorization Package

## Description
A Swift package providing optimized algorithms for prime factorization, prime checking, and prime number generation using the efficient 6k±1 optimization method. Includes both synchronous and async/await APIs for flexibility in different contexts.

Last Updated: 2026.03.16 **v2.0**

## Features

### Public Extensions on `Int`

- **`.primeFactors`**: `[Int]` - Returns all prime factors in ascending order
- **`.isPrime`**: `Bool` - Checks if the number is prime (O(√n) complexity)
- **`.largestPrimeFactor`**: `Int?` - Returns the largest prime factor, or `nil` if none exists
- **`.smallestPrimeFactor`**: `Int?` - Returns the smallest prime factor, or `nil` if none exists

### Synchronous Functions

- **`primeNumbers(from: Int = 2, through: Int) throws -> [Int]`** - Generate primes in a range
- **`allFactors(of n: Int) -> [Int]`** - Find all factors (divisors) of a number

### Configuration

- **`PrimeFactorizationSyncConfig.shared.maxPrimeRange`** - Thread-safe maximum range size for prime generation (default: 15,000,000)
  - Use in synchronous contexts
  - Can be adjusted based on your application's memory constraints and performance requirements
- **`PrimeFactorizationConfig.maxPrimeRange`** - Async actor-based configuration access
  - Use in async contexts for fully concurrent-safe access

### Async/Await Functions

- **`primeFactors(of: Int) async throws -> [Int]`** - Async prime factorization with cooperative cancellation
- **`primeFactorsOptimized(of: Int) async throws -> [Int]`** - Optimized async version using 6k±1 and small prime table
- **`primeFactorsConcurrent(of: [Int]) async throws -> [Int: [Int]]`** - Concurrent factorization of multiple numbers

### Array Extensions

- **`[Int].simpleArrayDescription`**: `String` - Format as "[2, 3, 5]"
- **`[Int].primeFactorizationString`**: `String` - Format as "2² × 3 × 5"

### Iterator Sequence

- **`PrimeIteratorSequence`** - Memory-efficient lazy iteration over prime numbers

## Usage Examples

### Synchronous Prime Operations

```swift
import PrimeFactorization

// Prime factorization
let factors = 60.primeFactors
// [2, 2, 3, 5] because 60 = 2² × 3 × 5

// Prime checking
let isPrime = 17.isPrime
// true

// Largest/smallest prime factor
if let largest = 100.largestPrimeFactor {
    print(largest)  // 5
}

// Generate primes in a range
do {
    let primes = try primeNumbers(from: 10, through: 30)
    // [11, 13, 17, 19, 23, 29]
} catch {
    print("Error: \(error)")
}

// All factors of a number
let factors = allFactors(of: 60)
// [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60]

// Lazy iteration over primes
for prime in PrimeIteratorSequence(from: 100, through: 200) {
    print(prime)
}
```

### Async Prime Factorization

```swift
import PrimeFactorization

// Single number factorization
let factors = try await primeFactors(of: 5040)
print(factors.primeFactorizationString)
// "2^4 × 3^2 × 5 × 7"

// Optimized version for better performance
let optimized = try await primeFactorsOptimized(of: 987654321)
print(optimized.simpleArrayDescription)
// "[3, 3, 17, 17, 379721]"

// Concurrent factorization of multiple numbers
let numbers = [12, 18, 24, 30]
let results = try await primeFactorsConcurrent(of: numbers)
// [12: [2, 2, 3], 18: [2, 3, 3], 24: [2, 2, 2, 3], 30: [2, 3, 5]]

for (num, factors) in results.sorted(by: { $0.key < $1.key }) {
    print("\(num) = \(factors.primeFactorizationString)")
}
```

### Formatted Output

```swift
let factors = [2, 2, 3, 3, 3, 5]

// Simple array format
print(factors.simpleArrayDescription)
// "[2, 2, 3, 3, 3, 5]"

// Mathematical notation with exponents
print(factors.primeFactorizationString)
// "2^2 × 3^3 × 5"
```

### Configuration

```swift
// Synchronous configuration (thread-safe with locks)
PrimeFactorizationSyncConfig.shared.maxPrimeRange = 50_000_000
let primes = try primeNumbers(through: 30_000_000)

// Async configuration (actor-based, fully concurrent-safe)
await PrimeFactorizationConfig.setMaxPrimeRange(50_000_000)
let currentMax = await PrimeFactorizationConfig.maxPrimeRange
```

## Error Handling

The package defines `PrimeFactorizationError` with two cases:
- `.invalidInput(String)` - Invalid arguments (e.g., negative numbers, inverted ranges)
- `.rangeTooLarge(Int)` - Requested range exceeds maximum allowed size

## Installation

Add this package as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/PrimeFactorization.git", from: "1.0.0")
]
```

## Performance

- Uses optimized **6k±1 method** for prime checking
- **Trial division** with overflow protection for factorization
- Efficient **O(√n)** complexity for most operations
- Async versions support **cooperative cancellation** for long-running computations
- **Concurrent processing** available for multiple numbers
- Can handle very large numbers up to `Int.max`

## Requirements

- Swift 6.0+
- Async/await features require macOS 10.15+ / iOS 13.0+ / watchOS 6.0+ / tvOS 13.0+
- No external dependencies

## API Availability

- **Synchronous APIs**: Available on all platforms
- **Async/await APIs**: Require macOS 10.15+, iOS 13.0+, watchOS 6.0+, tvOS 13.0+

## License

MIT License. Copyright (c) 2024-2026 Don Sleeter

