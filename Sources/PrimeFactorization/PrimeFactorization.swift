// The Swift Programming Language
// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/

import Foundation

public extension Int {

  /// Returns the prime factors of integer in ascending order
  /// - Returns: Array of prime factors, in order, empty array for numbers <= 1
  var primeFactors: [Int] {
    return primeFactorsOf(self)
  }

  /// Optimized prime factorization using trial division
  /// - Parameter number: The number to factorize
  /// - Returns: Array of prime factors in ascending order
  /// - note: this is a private func called by the public Int extension above
  /// - note: cannot throw because all numbers > 1 have prime factors
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
    var divisor = 5 // 5 = 6k-1 -> k = 1
    //while divisor * divisor <= n {
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


// Global cache for prime results
nonisolated(unsafe) private var primeCache: [Int: Bool] = [:]

// Optimized prime checking algorithm
public extension Int {
  var isPrime: Bool {
    // Check cache first
    if let cached = primeCache[self] {
      return cached
    }

    let result: Bool

    if self <= 1 {
      result = false
    } else if self <= 3 { // because 2 and 3 are both prime
      result = true
    } else if self & 1 == 0 || self % 3 == 0 {  // Bit operation for even check (instead of self % 2 == 0)
      result = false
    } else {
      let limit = Int(Double(self).squareRoot())
      var divisor = 5
      var found = false

      // Early exit optimization: uses a found flag to exit as soon as a divisor is found
      while divisor <= limit && !found {
        found = (self % divisor == 0) || (self % (divisor + 2) == 0)
        divisor += 6
      }
      result = !found
    }

    primeCache[self] = result
    return result
  }
}


public extension Int {
  /// Returns the largest prime factor, nil if no prime factors exist
  /// - note: assumes primeFactors is sorted ascending
  var largestPrimeFactor: Int? {
    let factors = self.primeFactors
    return factors.isEmpty ? nil : factors.last
  }

  /// Returns the smallest prime factor, nil if no prime factors exist
  /// - note: assumes primeFactors is sorted ascending
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
/// - Parameter limit: Integer upper bound for looking for primes
/// - Returns: Int array
/// - note: isPrimeArrray is a small boolean array (could be stored in bundle)
/// - THIS FUNCTION IS OBSOLETE, SLOWER THAN primeNumbers(from:through:)
public func primeNumbersUpTo(_ limit: Int) -> [Int] {
  guard limit >= 2 else { return [] }
  guard limit <= 2_000_000 else { return [] }  // above this takes too much time
  var isPrimeArrray = Array(repeating: true, count: limit + 1) // allocate array set all true
  isPrimeArrray[0] = false
  isPrimeArrray[1] = false
  
  for i in 1...Int(Double(limit).squareRoot()) {  // check from 1 up to square root of limit
    if isPrimeArrray[i] {
      for j in stride(from: i * i, through: limit, by: i) { // set all squares to false
        isPrimeArrray[j] = false
      }
    }
  }
  // return an array of offsets where isPrime array element is still true
  return isPrimeArrray.enumerated().compactMap { $0.element ? $0.offset : nil }
}

/// Prime numbers in range using 6k±1 method.
/// - Parameters:
///   - start: the lower bound of the range
///   - end: the upper bound of the range
/// - Returns: an array of prime numbers between start and end, inclusively
/// - note: will not work for ranges that span more than 100 billion
private func primesByJump6Method(from start: Int = 5, through end: Int = 500) -> [Int] {
  guard start <= end         else { return [] }
  guard start >= 1           else { return [] }
  guard end   >= 2           else { return [] }
  //guard end   <= Int.max /*- 6*/ else { return [] }
  guard end-start <= 100_000_000_000 else { return [] }  // The span (end-start) should be less than this

  var primes: [Int] = []

  if start == 1 {
    primes.append(2)
    if end == 2 { return primes }
    if end >= 3 { primes.append(3) }
  }
  if start == 2 {
    primes.append(2)
    if end == 2 { return primes }
    if end >= 3 { primes.append(3) }
  }
  if start == 3 {
    primes.append(3)
  }

  var cursor = startCursor(from: start)

  while cursor <= end && cursor+2 < Int.max - 6 {
    [cursor, cursor + 2]
      .filter { $0.isPrime }  // if either is prime
      .forEach { $0 <= end ? primes.append($0) : () }
    cursor += 6
  }

  return primes
}

//struct Cursor {
//  var value: Int
//  var next: Int
//  init(value: Int) {
//    self.value = value
//    self.next = value + 2
//  }
//  var description: String { "[\(value) \(next)]" }
//}

/// given a start value, find the next jump6 cursor value equal to or above it
/// for example:
/// given 12, we want to return 17
/// given 5, we want to return 5
/// given 21, we want to return 23
///
/// Simplified logic: Instead of 6 - (start % 6) - 1, we use (5 - start % 6 + 6) % 6 which is more direct
func startCursor(from start: Int) -> Int {
  return start + (5 - start % 6 + 6) % 6
}


/// Generate array of prime numbers in a range using 6k±1 method
/// - Parameters:
///   - from: Optional argument - lower bound of range, default 2
///   - through: Required argument - for upper bound of range
/// - Returns: [Int] - array of Int
@available(macOS 12.0, *)
public func primeNumbers(from startIndex: Int = 2, through endIndex: Int) -> [Int] {

  // boudary error check the arguments here in the public API
  guard startIndex > 0 else {
    fatalError("\(startIndex) must be > 0. Argument out of range")
  }

  guard startIndex <= endIndex else {
    print("startIndex \(startIndex) must be less than or equal to \(endIndex)")
    //throw PrimeFactorizationError.invalidInput("startIndex must be less than or equal to endIndex")
    return []
  }

  // sanity check
  guard endIndex-startIndex <= 15_000_000 else { // startIndex and endIndex can be way bigger, but the range.count needs be less than this
    fatalError("the range must be less than or equal to 15_000_000")
  }

  // Private prime checking using 6k±1 method. Array of Int (not Sequence)
  let allPrimes = primesByJump6Method(from: startIndex, through: endIndex)

  return allPrimes
}


/// Prime Number Iterator in a Sequence -- can handle huge numbers.
/// A PrimeIteratorSequence iteratively generates a Swift Sequence of prime numbers.
/// Benefits of using a PrimeIteratorSequence:
/// * Memory Efficiency: An iterator can generate primes on demand rather than storing a potentially large list of primes in memory.
/// * Flexibility: It can be designed to generate primes up to a specific limit or to continue infinitely.
/// * Readability: Structuring the code into a dedicated iterator class can make the
/// prime number generation logic more organized and easier to understand. Encapsulate boundary conditions.
///
/// The logic for finding and providing the next prime number in the sequence. It can be based on different algorithms, such as:
/// Trial Division: Checking if a number is divisible by any smaller prime numbers up to its square root.
/// Sieve of Eratosthenes: An efficient algorithm to find all primes up to a given limit by iteratively marking multiples of primes as non-prime.
/// Other Prime Number Sieves: Like the Sieve of Atkin or Sieve of Sundaram, offering further optimizations.

struct PrimeIteratorSequence: Sequence, IteratorProtocol {
  typealias Element = Int // generalize this below

  private var allPrimes: [Element] = []

  // does it make sense to have a failable init here?
  init(from startIndex: Element = 2, through endIndex: Element = 100) { // by default start at 2, stop at 100

    guard startIndex > 0 else {
      fatalError("\(startIndex) must be > 0. Argument out of range")
    }

    guard startIndex <= endIndex else {
      fatalError("\(startIndex) must be less than or equal to \(endIndex)")
    }

    guard endIndex-startIndex <= 15_000_000 else { // from and through can be way bigger, but the range.count needs sanity
      fatalError("the range must be less than or equal to 15_000_000")
    }

    // guard endIndex <= Int.max else {
    //   fatalError( "\(endIndex) is too large")
    // }

    allPrimes = primesByJump6Method(from: startIndex, through: endIndex).reversed()
    //print("allPrimes.count \(allPrimes.count)")
  }

  // seems that we could better use the cursor function to find the next prime, instead of computing all of them
  mutating func next() -> Int? {
    return allPrimes.popLast()
  }
}

struct BrokenPrimeIterator2Sequence: Sequence, IteratorProtocol {
  typealias Element = Int // genericize this below

  private var allPrimes: [Element] = []
  private var currentIndex: Int
  private var startIndex: Int
  private var endIndex: Int

  // does it make sense to have a failable init here?
  init(from startIndex: Element = 2, through endIndex: Element = 100) { // by default start at 2, stop at 100

    guard startIndex > 0 else {
      fatalError("\(startIndex) must be > 0. Argument out of range")
    }

    guard startIndex <= endIndex else {
      fatalError("\(startIndex) must be less than or equal to \(endIndex)")
    }

    guard endIndex-startIndex <= 15_000_000 else { // from and through can be way bigger, but the range.count needs sanity
      fatalError("the range must be less than or equal to 15_000_000")
    }

    // guard endIndex <= Int.max else {
    //   fatalError( "\(endIndex) is too large")
    // }

    self.currentIndex = startIndex
    self.startIndex = startIndex
    self.endIndex = endIndex

    allPrimes = primesByJump6Method(from: startIndex, through: endIndex).reversed()
    //print("allPrimes.count \(allPrimes.count)")
  }

  // seems that we could better use the cursor function to find the next prime, instead of computing all of them
  mutating func next() -> Int? {

    // compute the cursor values to check isPrime.. Use a stridable sequence here.
    //var cursors: (Int,Int) = startCursor(from: currentIndex)
    //var cursor = startCursor(from: currentIndex)

    // while cursors.0 <= endIndex { // && cursor.1 < Int.max - 6
    //   [cursors.0, cursors.1]
    //     .filter { $0.isPrime }  // if either cursor is prime
    //     .forEach { $0 <= endIndex ? allPrimes.append($0) : () }
    //   cursors.0 += 6  // ?? not smart at all
    // }
    var cursor = startCursor(from: endIndex)

    while cursor <= endIndex && cursor+2 < Int.max - 6 {
      [cursor, cursor + 2]
        .filter { $0.isPrime }
        .forEach { $0 <= endIndex ? allPrimes.append($0) : () }
      cursor += 6
    }
    return allPrimes.popLast()
  }
}

//enum PrimeFactorizationError: Error, Equatable {
//  case invalidInput(Int)
//  case rangeTooLarge
//}
