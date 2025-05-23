// The Swift Programming Language
// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/

import Foundation

public extension Int {
  /// Returns the prime factors of the integer in ascending order
  /// - Returns: Array of prime factors, empty array for numbers <= 1
  var primeFactors: [Int] {
    return optimizedPrimeFactorsOf(self)
  }

  /// Optimized prime factorization using trial division
  /// - Parameter number: The number to factorize
  /// - Returns: Array of prime factors in ascending order
  private func optimizedPrimeFactorsOf(_ number: Int) -> [Int] {
    // Handle edge cases
    guard number > 1 else { return [] }

    var n = number
    var factors: [Int] = []

    // Handle factor 2 separately (only even prime)
    while n % 2 == 0 {
      factors.append(2)
      n /= 2
    }

    // Handle factor 3 separately
    while n % 3 == 0 {
      factors.append(3)
      n /= 3
    }

    // Check potential factors of form 6k±1
    var divisor = 5
    while divisor * divisor <= n {
      // Check 6k-1
      while n % divisor == 0 {
        factors.append(divisor)
        n /= divisor
      }

      // Check 6k+1
      while n % (divisor + 2) == 0 {
        factors.append(divisor + 2)
        n /= (divisor + 2)
      }

      divisor += 6
    }

    // If n is still > 1, then it's a prime factor
    if n > 1 {
      factors.append(n)
    }

    return factors
  }
}

public extension Int {
  /// Optimized prime checking using 6k±1 method
  var isPrimeOptimized: Bool {
    switch self {
      case ...1:
        return false
      case 2, 3:
        return true
      case _ where self % 2 == 0 || self % 3 == 0:
        return false
      default:
        var divisor = 5
        while divisor * divisor <= self {
          if self % divisor == 0 || self % (divisor + 2) == 0 {
            return false
          }
          divisor += 6
        }
        return true
    }
  }
}

public extension Int {
  /// Returns the largest prime factor, nil if no prime factors exist
  var largestPrimeFactor: Int? {
    let factors = self.primeFactors
    return factors.isEmpty ? nil : factors.last
  }

  /// Returns the smallest prime factor, nil if no prime factors exist
  var smallestPrimeFactor: Int? {
    let factors = self.primeFactors
    return factors.isEmpty ? nil : factors.first
  }
}

/// Optimized function to find all factors of a number
public func allFactors(of n: Int) -> [Int] {
  guard n > 0 else { return [] }

  let sqrtN = Int(Double(n).squareRoot())
  var factors: [Int] = []
  factors.reserveCapacity(2 * sqrtN)

  for i in 1...sqrtN {
    if n % i == 0 {
      factors.append(i)
      if i != n / i { // Avoid duplicating perfect squares
        factors.append(n / i)
      }
    }
  }

  return factors.sorted()
}

/// Sieve of Eratosthenes for efficient prime generation
public func primeNumbersUpTo(_ limit: Int) -> [Int] {
  guard limit >= 2 else { return [] }
  guard limit <= 1_000_000 else { return [] }  // above this takes too much time
  var isPrime = Array(repeating: true, count: limit + 1)
  isPrime[0] = false
  isPrime[1] = false

  for i in 1...Int(Double(limit).squareRoot()) {
    if isPrime[i] {
      for j in stride(from: i * i, through: limit, by: i) {
        isPrime[j] = false
      }
    }
  }

  return isPrime.enumerated().compactMap { $0.element ? $0.offset : nil }
}

/// Generate primes in a range using sieve method
public func primeNumbers(from: Int = 2, through: Int) -> [Int] {
  guard through >= from && from >= 2 else { return [] }

  let allPrimes = primeNumbersUpTo(through)
  return allPrimes.filter { $0 >= from }
}

/// Improved Prime Iterator using lazy evaluation
struct PrimeIteratorSequence: Sequence, IteratorProtocol {
  typealias Element = Int

  private let from: Int
  private let through: Int
  private var current: Int

  init(from: Int = 2, through: Int) {
    self.from = Swift.max(2, from)
    self.through = through
    self.current = self.from
  }

  mutating func next() -> Int? {
    while current <= through {
      let candidate = current
      current += (current == 2) ? 1 : 2 // Skip even numbers after 2

      if candidate.isPrimeOptimized {
        return candidate
      }
    }
    return nil
  }
}

enum PrimeFactorizationError: Error {
  case invalidInput(Int)
}


/*
 I'll provide a comprehensive review of your Prime Factorization Swift code. Overall, this is a well-documented implementation with some interesting optimizations, but there are several areas for improvement.

 ## **Strengths**

 **Good Documentation**: Excellent use of Swift documentation comments with clear parameter descriptions and return value explanations.

 **Mathematical Optimization**: Smart use of the 6n±1 optimization for prime checking, which is mathematically sound since all primes > 3 are of the form 6k±1.

 **Multiple Implementations**: Providing both `isPrime` and `isPrime2` variants allows for performance comparison.

 ## **Critical Issues**

 ### 1. **Incorrect Prime Factorization Algorithm**
 The main `primeFactorsOf` function has a fundamental flaw:

 ```swift
 // Current problematic code
 for bigDivisor in [2, 3, jumpDivisor, jumpDivisor + 2] {
 ```

 This inner loop is incorrect because:
 - It redundantly checks 2 and 3 on every iteration
 - The 6n±1 optimization is misapplied - you should only check `jumpDivisor` and `jumpDivisor + 2`
 - The algorithm doesn't properly handle repeated prime factors

 **Example Bug**: `12.primeFactors` might return `[2, 6]` instead of `[2, 2, 3]`

 ### 2. **Edge Case Handling Issues**
 ```swift
 guard number > 3 else { return [number] }
 ```

 This returns `[0]`, `[1]`, `[-5]` etc., which are incorrect since these numbers don't have prime factorizations.

 ### 3. **Performance Problems**
 The `newPrimeFactorsOf` function generates all primes up to √n on every recursive call, which is extremely inefficient.

 ## **Recommended Fixes**

 ## **Additional Swift/SwiftUI Specific Recommendations**

 ### 1. **Property Naming Conventions**
 ```swift
 // Better naming following Swift conventions
 var largestPrimeFactor: Int? // Instead of largestPrime
 var smallestPrimeFactor: Int? // Instead of smallestPrime
 ```

 ### 2. **Error Handling**
 Consider using Result types or throwing functions for invalid inputs:
 ```swift
 enum PrimeFactorizationError: Error {
 case invalidInput(Int)
 }

 func primeFactors(of number: Int) throws -> [Int]
 ```

 ### 3. **Performance Considerations for SwiftUI**
 If using this in SwiftUI views, consider:
 - Making expensive computations `@State` or `@StateObject` properties
 - Using `Task` for async computation of large numbers
 - Implementing cancellation for long-running operations

 ### 4. **Memory Optimization**
 ```swift
 // Use lazy evaluation for large sequences
 lazy var primeSequence = PrimeIteratorSequence(from: 2, through: 1000)
 ```

 ## **Testing Recommendations**

 Add comprehensive unit tests covering:
 - Edge cases: 0, 1, 2, 3, negative numbers
 - Perfect squares: 4, 9, 16, 25
 - Large primes: 97, 101, 997
 - Composite numbers: 12, 60, 100

 ## **Overall Assessment**

 The code shows good understanding of mathematical optimizations, but the core prime factorization algorithm needs fixing. The documentation is excellent, and the performance considerations show thoughtful engineering. With the suggested corrections, this would be a solid, production-ready implementation.

 The main areas to focus on are:
 1. Fix the factorization algorithm logic
 2. Improve edge case handling
 3. Optimize the recursive approach
 4. Add proper error handling

 Would you like me to elaborate on any specific aspect or help you implement unit tests for the corrected version?
 */
