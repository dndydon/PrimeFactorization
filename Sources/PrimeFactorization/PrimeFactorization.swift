// The Swift Programming Language
// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/

import Foundation

// MARK: - Error Types

/// Errors that can occur during prime factorization operations
public enum PrimeFactorizationError: Error, Equatable {
  /// The input value is invalid (e.g., negative or zero where positive is required)
  case invalidInput(String)
  /// The requested range is too large to process efficiently
  case rangeTooLarge(Int)
}

// MARK: - Constants

/// Configuration for prime factorization operations.
///
/// This actor provides thread-safe access to configuration values that can be modified
/// at runtime, such as the maximum range size for prime generation.
///
/// Example:
/// ```swift
/// // Allow larger ranges for servers with more memory
/// await PrimeFactorizationConfig.setMaxPrimeRange(50_000_000)
/// let currentMax = await PrimeFactorizationConfig.maxPrimeRange
/// ```
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public actor PrimeFactorizationConfig {
  /// Gets the current maximum prime range size.
  public static var maxPrimeRange: Int {
    get async {
      await shared.getMaxRange()
    }
  }
  
  /// Sets the maximum prime range size.
  ///
  /// - Parameter value: The new maximum range size. Must be positive.
  public static func setMaxPrimeRange(_ value: Int) async {
    await shared.setMaxRange(value)
  }
  
  private static let shared = PrimeFactorizationConfig()
  
  private var currentMaxRange: Int = 15_000_000
  
  private init() {}
  
  private func getMaxRange() -> Int {
    return currentMaxRange
  }
  
  private func setMaxRange(_ value: Int) {
    currentMaxRange = value
  }
}

/// Synchronous configuration access for non-async contexts.
///
/// This provides thread-safe access to configuration using a lock-based approach
/// for code that cannot use async/await.
///
/// Thread safety is guaranteed through NSLock synchronization.
public final class PrimeFactorizationSyncConfig: @unchecked Sendable {
  private let lock = NSLock()
  private var _maxPrimeRange: Int = 15_000_000
  
  /// Shared singleton instance
  public static let shared = PrimeFactorizationSyncConfig()
  
  private init() {}
  
  /// Maximum range size for prime generation. Default is 15,000,000.
  ///
  /// This property is thread-safe and can be accessed from any context.
  public var maxPrimeRange: Int {
    get {
      lock.lock()
      defer { lock.unlock() }
      return _maxPrimeRange
    }
    set {
      lock.lock()
      defer { lock.unlock() }
      _maxPrimeRange = newValue
    }
  }
}

/// Maximum span for the jump-6 method
private let maxJump6Span = 100_000_000_000

// MARK: - Prime Factorization

public extension Int {

  /// Returns the prime factors of the integer in ascending order.
  ///
  /// Prime factorization decomposes a number into its prime components using an optimized
  /// trial division algorithm with 6k±1 optimization.
  ///
  /// - Returns: An array of prime factors in ascending order. Returns an empty array for numbers ≤ 1.
  /// - Complexity: O(√n) where n is the value of `self`.
  ///
  /// Example:
  /// ```swift
  /// let factors = 60.primeFactors
  /// // factors == [2, 2, 3, 5]
  /// // because 60 = 2² × 3 × 5
  /// ```
  var primeFactors: [Int] {
    return primeFactorsOf(self)
  }

  /// Optimized prime factorization using trial division with 6k±1 optimization
  /// - Parameter number: The number to factorize
  /// - Returns: Array of prime factors in ascending order
  private func primeFactorsOf(_ number: Int) -> [Int] {
    // Handle edge cases
    guard number > 1 else { return [] }

    var n = number
    var factors: [Int] = []

    // Handle factor 2 separately (the only even prime)
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
    var divisor = 5 // 5 = 6k-1 where k = 1
    while divisor <= n / divisor {  // Overflow protection
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


// MARK: - Prime Checking

/// Optimized prime checking algorithm using 6k±1 optimization
public extension Int {
  /// Checks if the integer is a prime number.
  ///
  /// A prime number is a natural number greater than 1 that has no positive divisors other than 1 and itself.
  ///
  /// - Returns: `true` if the number is prime, `false` otherwise.
  /// - Complexity: O(√n) where n is the value of `self`.
  ///
  /// Example:
  /// ```swift
  /// 7.isPrime  // true
  /// 10.isPrime // false
  /// ```
  var isPrime: Bool {
    if self <= 1 {
      return false
    } else if self <= 3 {
      return true
    } else if self & 1 == 0 || self % 3 == 0 {  // Bit operation for even check
      return false
    } else {
      let limit = Int(Double(self).squareRoot())
      var divisor = 5
      
      // Early exit optimization: exit as soon as a divisor is found
      while divisor <= limit {
        if self % divisor == 0 || self % (divisor + 2) == 0 {
          return false
        }
        divisor += 6
      }
      return true
    }
  }
}

// MARK: - Prime Factor Utilities

public extension Int {
  
  /// Returns the largest prime factor of the integer.
  ///
  /// - Returns: The largest prime factor, or `nil` if the number has no prime factors (≤ 1).
  /// - Complexity: O(√n) where n is the value of `self`.
  ///
  /// Example:
  /// ```swift
  /// 60.largestPrimeFactor  // Optional(5)
  /// 1.largestPrimeFactor   // nil
  /// ```
  var largestPrimeFactor: Int? {
    return self.primeFactors.max()
  }

  /// Returns the smallest prime factor of the integer.
  ///
  /// - Returns: The smallest prime factor, or `nil` if the number has no prime factors (≤ 1).
  /// - Complexity: O(√n) where n is the value of `self`.
  ///
  /// Example:
  /// ```swift
  /// 60.smallestPrimeFactor  // Optional(2)
  /// 1.smallestPrimeFactor   // nil
  /// ```
  var smallestPrimeFactor: Int? {
    return self.primeFactors.min()
  }
}

// MARK: - All Factors

/// Returns all factors (divisors) of a number in ascending order.
///
/// This function efficiently finds all factors by only checking up to the square root
/// of the number, then collecting both the divisor and its complement.
///
/// - Parameter n: The number to find factors for. Must be positive.
/// - Returns: An array of all factors in ascending order. Returns empty array for n ≤ 0.
/// - Complexity: O(√n)
///
/// Example:
/// ```swift
/// allFactors(of: 60)
/// // [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60]
/// ```
public func allFactors(of n: Int) -> [Int] {
  guard n > 0 else { return [] }
  if n == 1 { return [1] }

  let sqrtN = Int(Double(n).squareRoot())
  var lowFactors: [Int] = []
  var highFactors: [Int] = []

  for i in 1...sqrtN {
    if n % i == 0 {
      lowFactors.append(i)
      let complement = n / i
      if i != complement { // Avoid duplicating perfect squares
        highFactors.append(complement)
      }
    }
  }

  return lowFactors + highFactors.reversed()
}

// MARK: - Prime Generation (6k±1 Method)

/// Generates prime numbers in a range using the optimized 6k±1 method.
///
/// This is a private implementation that uses the mathematical property that all primes
/// greater than 3 can be expressed as 6k±1 for some integer k.
///
/// - Parameters:
///   - start: The lower bound of the range (inclusive).
///   - end: The upper bound of the range (inclusive).
/// - Returns: An array of prime numbers between start and end, inclusively.
private func primesByJump6Method(from start: Int = 5, through end: Int = 500) -> [Int] {
  guard start <= end else { return [] }
  guard start >= 1 else { return [] }
  guard end >= 2 else { return [] }
  guard end - start <= maxJump6Span else { return [] }

  var primes: [Int] = []

  // Handle special cases for 2 and 3
  if start <= 2 && end >= 2 { primes.append(2) }
  if start <= 3 && end >= 3 { primes.append(3) }

  // Use 6k±1 optimization for numbers >= 5
  var cursor = startCursor(from: start)

  while cursor <= end && cursor + 2 < Int.max - 6 {
    [cursor, cursor + 2]
      .filter { $0.isPrime && $0 <= end }
      .forEach { primes.append($0) }
    cursor += 6
  }

  return primes
}

/// Finds the next 6k-1 cursor value equal to or above the given start value.
///
/// This helper function aligns a starting position to the nearest value of the form 6k-1,
/// which is used in the 6k±1 prime-finding optimization.
///
/// - Parameter start: The starting value to align.
/// - Returns: The next value of the form 6k-1 that is >= start.
///
/// Examples:
/// - `startCursor(from: 5)` returns 5 (already 6×1-1)
/// - `startCursor(from: 12)` returns 17 (6×3-1)
/// - `startCursor(from: 21)` returns 23 (6×4-1)
func startCursor(from start: Int) -> Int {
  return start + (5 - start % 6 + 6) % 6
}


// MARK: - Public Prime Generation API

/// Generates an array of prime numbers in a specified range using the 6k±1 method.
///
/// This is an optimized prime generation function that can handle large ranges efficiently.
/// It uses the mathematical property that all primes > 3 are of the form 6k±1.
///
/// - Parameters:
///   - startIndex: The lower bound of the range (inclusive). Must be positive. Default is 2.
///   - endIndex: The upper bound of the range (inclusive). Must be >= startIndex.
/// - Returns: An array of all prime numbers in the range [startIndex, endIndex].
/// - Throws: ``PrimeFactorizationError/invalidInput(_:)`` if arguments are invalid,
///           or ``PrimeFactorizationError/rangeTooLarge(_:)`` if the range is too large.
/// - Complexity: O(n√n) where n is the size of the range.
///
/// Example:
/// ```swift
/// let primes = try primeNumbers(from: 10, through: 30)
/// // [11, 13, 17, 19, 23, 29]
/// ```
public func primeNumbers(from startIndex: Int = 2, through endIndex: Int) throws -> [Int] {
  
  // Validate arguments
  guard startIndex > 0 else {
    throw PrimeFactorizationError.invalidInput("startIndex must be > 0, got \(startIndex)")
  }

  guard startIndex <= endIndex else {
    throw PrimeFactorizationError.invalidInput("startIndex (\(startIndex)) must be <= endIndex (\(endIndex))")
  }

  guard endIndex - startIndex <= PrimeFactorizationSyncConfig.shared.maxPrimeRange else {
    throw PrimeFactorizationError.rangeTooLarge(endIndex - startIndex)
  }

  return primesByJump6Method(from: startIndex, through: endIndex)
}


// MARK: - Prime Iterator Sequence

/// A sequence that generates prime numbers lazily within a given range.
///
/// `PrimeIteratorSequence` provides memory-efficient iteration over prime numbers by
/// generating them on-demand rather than storing them all in memory at once.
///
/// Benefits:
/// - **Memory Efficiency**: Generates primes on demand rather than pre-computing all values
/// - **Flexibility**: Works with very large ranges
/// - **Standard Iteration**: Conforms to Swift's `Sequence` protocol
///
/// Example:
/// ```swift
/// let primes = PrimeIteratorSequence(from: 100, through: 200)
/// for prime in primes {
///     print(prime)
/// }
/// ```
///
/// - Note: Currently pre-computes all primes in the range. Future optimization could
///         generate primes lazily using the cursor method.
public struct PrimeIteratorSequence: Sequence, IteratorProtocol {
  public typealias Element = Int

  private var allPrimes: [Element] = []

  /// Creates a new prime iterator for the specified range.
  ///
  /// - Parameters:
  ///   - startIndex: The lower bound (inclusive). Must be positive. Default is 2.
  ///   - endIndex: The upper bound (inclusive). Must be >= startIndex. Default is 100.
  /// - Throws: Triggers a runtime error if arguments are invalid or range is too large.
  ///
  /// - Warning: This initializer uses `fatalError()` for invalid inputs. Consider using
  ///            ``primeNumbers(from:through:)`` for proper error handling.
  public init(from startIndex: Element = 2, through endIndex: Element = 100) {
    
    guard startIndex > 0 else {
      fatalError("\(startIndex) must be > 0. Argument out of range")
    }

    guard startIndex <= endIndex else {
      fatalError("\(startIndex) must be less than or equal to \(endIndex)")
    }

    guard endIndex - startIndex <= PrimeFactorizationSyncConfig.shared.maxPrimeRange else {
      fatalError("the range must be less than or equal to \(PrimeFactorizationSyncConfig.shared.maxPrimeRange)")
    }

    allPrimes = primesByJump6Method(from: startIndex, through: endIndex).reversed()
  }

  /// Returns the next prime number in the sequence.
  ///
  /// - Returns: The next prime, or `nil` if the sequence is exhausted.
  public mutating func next() -> Int? {
    return allPrimes.popLast()
  }
}

// MARK: - Async Prime Factorization

/// Computes prime factors of a number using async/await for cooperative cancellation.
///
/// This async version yields periodically during computation, allowing for cooperative
/// cancellation and better responsiveness in concurrent contexts.
///
/// - Parameter number: The number to factorize. Must be > 1.
/// - Returns: An array of prime factors in ascending order.
/// - Throws: ``PrimeFactorizationError/invalidInput(_:)`` if the number is ≤ 1.
///
/// Example:
/// ```swift
/// let factors = try await primeFactors(of: 12345)
/// // [3, 5, 823]
/// ```
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func primeFactors(of number: Int) async throws -> [Int] {
  guard number > 1 else {
    throw PrimeFactorizationError.invalidInput("Number must be greater than 1, got \(number)")
  }
  var factors: [Int] = []
  var n = number

  // Check for factor 2
  while n % 2 == 0 {
    factors.append(2)
    n = n / 2
  }

  // Check for odd factors from 3 onwards
  var i = 3
  while i * i <= n {
    while n % i == 0 {
      factors.append(i)
      n = n / i
      // Yield periodically for long computations
      if factors.count % 1000 == 0 {
        await Task.yield()
      }
    }
    i += 2
    // Yield periodically when checking large divisors
    if i % 10000 == 1 {
      await Task.yield()
    }
  }

  // If n is still greater than 1, then it's a prime factor
  if n > 1 {
    factors.append(n)
  }

  return factors
}

/// Optimized async version using 6k±1 optimization and small prime table.
///
/// This is generally faster than the standard async version for most numbers,
/// especially when the number has small prime factors.
///
/// - Parameter number: The number to factorize. Must be > 1.
/// - Returns: An array of prime factors in ascending order.
/// - Throws: ``PrimeFactorizationError/invalidInput(_:)`` if the number is ≤ 1.
///
/// Example:
/// ```swift
/// let factors = try await primeFactorsOptimized(of: 5040)
/// // [2, 2, 2, 2, 3, 3, 5, 7]
/// ```
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func primeFactorsOptimized(of number: Int) async throws -> [Int] {
  guard number > 1 else {
    throw PrimeFactorizationError.invalidInput("Number must be greater than 1, got \(number)")
  }

  var factors: [Int] = []
  var n = number
  
  // Pre-computed small primes for faster initial factorization
  let smallPrimes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
  for prime in smallPrimes {
    while n % prime == 0 {
      factors.append(prime)
      n = n / prime
    }
    if n == 1 { return factors }
  }
  
  // Use 6k±1 optimization for remaining factors
  var i = 37
  while i * i <= n {
    while n % i == 0 {
      factors.append(i)
      n = n / i
    }
    let next = i + 4
    if next * next <= n {
      while n % next == 0 {
        factors.append(next)
        n = n / next
      }
    }
    i += 6
    // Yield periodically for very large numbers
    if i % 10000 == 1 {
      await Task.yield()
    }
  }
  
  if n > 1 {
    factors.append(n)
  }
  
  return factors
}

/// Computes prime factors for multiple numbers concurrently.
///
/// This function uses structured concurrency to factorize multiple numbers in parallel,
/// which can significantly speed up processing of many numbers.
///
/// - Parameter numbers: An array of numbers to factorize. All must be > 1.
/// - Returns: A dictionary mapping each number to its prime factors.
/// - Throws: ``PrimeFactorizationError/invalidInput(_:)`` if any number is ≤ 1.
///
/// Example:
/// ```swift
/// let results = try await primeFactorsConcurrent(of: [12, 18, 24])
/// // [12: [2, 2, 3], 18: [2, 3, 3], 24: [2, 2, 2, 3]]
/// ```
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func primeFactorsConcurrent(of numbers: [Int]) async throws -> [Int: [Int]] {
  return try await withThrowingTaskGroup(of: (Int, [Int]).self) { group in
    var results: [Int: [Int]] = [:]
    
    for number in numbers {
      group.addTask {
        let factors = try await primeFactors(of: number)
        return (number, factors)
      }
    }
    
    for try await (number, factors) in group {
      results[number] = factors
    }
    
    return results
  }
}

// MARK: - Array Extensions

public extension Array where Element == Int {
  
  /// Returns a simple string representation of the array.
  ///
  /// Example:
  /// ```swift
  /// [2, 2, 3, 5].simpleArrayDescription
  /// // "[2, 2, 3, 5]"
  /// ```
  var simpleArrayDescription: String {
    "[" + self.map(String.init).joined(separator: ", ") + "]"
  }
  
  /// Returns a string representation of prime factorization with exponents.
  ///
  /// Example:
  /// ```swift
  /// [2, 2, 3, 3, 3, 5].primeFactorizationString
  /// // "2^2 × 3^3 × 5"
  /// ```
  var primeFactorizationString: String {
    let factorCounts = self.reduce(into: [:]) { counts, factor in
      counts[factor, default: 0] += 1
    }
    return factorCounts
      .sorted { $0.key < $1.key }
      .map { factor, count in
        count == 1 ? "\(factor)" : "\(factor)^\(count)"
      }
      .joined(separator: " × ")
  }
}



