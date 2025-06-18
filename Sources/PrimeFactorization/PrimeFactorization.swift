// The Swift Programming Language
// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/

import Foundation

public extension Int {
  /// Returns the prime factors of self integer in ascending order
  /// - Returns: Array of prime factors, empty array for numbers <= 1
  var primeFactors: [Int] {
    return primeFactorsOf(self)
  }

  /// Optimized prime factorization using trial division
  /// - Parameter number: The number to factorize
  /// - Returns: Array of prime factors in ascending order
  /// - note: this is a private func called by the Int public extension above
  private func primeFactorsOf(_ number: Int) -> [Int] {
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
  /// Optimized prime checking using 6k±1 method.
  /// Add a cache lookup here -- the cache never invalidates, and we don't want to calculate redundantly
  var isPrime: Bool {
    switch self {
      case ...1:
        return false
      case 2, 3:
        return true
      case _ where self % 2 == 0 || self % 3 == 0:
        return false
      default:

         let maxMagnitude = Self.max  //.magnitude
         let maxRoot = Int(Double(maxMagnitude).squareRoot())

        // print("max magnitude:", maxMagnitude, "max root:", maxRoot)

        var divisor = 5
//        guard divisor <= maxRoot else {
//          print ("divisor out of bounds: \(maxRoot)")
//          fatalError()
//        }
        while divisor * divisor <= self {   // arithmetic overflow error can happen here
          if self % divisor == 0 || self % (divisor + 2) == 0 {
            return false
          }
          divisor += 6
          if divisor > maxRoot {
            //print ("\(self) divisor \(divisor) out of bounds: \(maxRoot)")
            break
          }
        }
        return true
    }
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
/// - Parameter limit: Integer upper bound for looking for primes
/// - Returns: Int array
/// - note: isPrimeArrray
public func primeNumbersUpTo(_ limit: Int) -> [Int] {
  guard limit >= 2 else { return [] }
  guard limit <= 1_000_000 else { return [] }  // above this takes too much time
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

/// Generate primes in a range using sieve method
public func primeNumbers(from: Int = 2, through: Int) -> [Int] {
  guard through >= from else { return [] }  //&& from >= 2

  let allPrimes = primeNumbersUpTo(through)
  return allPrimes.filter { $0 >= from }
}


/// Improved Prime Iterator using lazy evaluation
struct PrimeIteratorSequence: Sequence, IteratorProtocol {
  typealias Element = Int // generalize this below

  private let from: Element
  private let through: Element  // if nil, how about just the next prime?
  private var current: Element

  init(from startIndex: Element = 2, through endIndex: Element = 37) {

    guard startIndex > 0 else {
      fatalError("\(startIndex) must be > 0. Argument out of range")
    }

    guard startIndex <= endIndex else {
      fatalError("\(startIndex) must be less than or equal to \(endIndex)")
    }

    // let maxMagnitude = Int.max.magnitude
    // let maxRoot = Int(Double(maxMagnitude).squareRoot())
    // print("max magnitude:", maxMagnitude, "max root:", maxRoot)

    // don't want even startIndex (unless it is 2, which is the default)
    self.from = startIndex == 2 ? startIndex : startIndex % 2 == 1 ? startIndex : startIndex + 1

    self.current = self.from

    if endIndex >= Int(Int.max.magnitude) {
      self.through = Int(Int.max.magnitude - 1)
    } else {
      self.through = endIndex
    }

  }

    mutating func next() -> Int? {
    while current <= through {
      let candidate = current

      // Wait, what about: Check potential factors of form 6k±1 instead?
      current += (current == 2) ? 1 : 2 // Skip even numbers after 2

      // Check potential factors using 6k±1 algorithm (Or, we could use a cache of the primes in there)
      if candidate.isPrime {
        return candidate
      }
    }
    return nil
  }
}

enum PrimeFactorizationError: Error {
  case invalidInput(Int)
}
