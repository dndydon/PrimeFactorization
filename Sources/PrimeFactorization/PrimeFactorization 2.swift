//
//  PrimeFactorization.swift
//  PrimeFactorization
//
//  Core algorithms and error definitions for prime factorization.
//

import Foundation

/// Custom error type for prime factorization operations
public enum PrimeFactorizationError: Error, LocalizedError {
  case invalidNumber
//  case computationTimeout

  public var errorDescription: String? {
    switch self {
      case .invalidNumber:
        return "Number must be greater than 1"
//      case .computationTimeout:
//        return "Computation timed out"
    }
  }
}

/// Computes prime factors of a large number using async/await
/// - Parameter number: The number to factorize
/// - Returns: Array of prime factors in ascending order
/// - Throws: PrimeFactorizationError if the number is invalid
@available(macOS 10.15, *)
public func primeFactors(of number: Int) async throws -> [Int] {
  guard number > 1 else {
    throw PrimeFactorizationError.invalidNumber
  }

  var factors: [Int] = []
  var n = number

  // Check for factor 2
  while n % 2 == 0 {
    factors.append(2)
    n = n / 2
//    if factors.count % 2 == 0 {  // factors.count % 1000 == 0 will "never" happen ??? what would be better?
//      print(factors)
//      await Task.yield()
//    }
  }

  // Check for odd factors from 3 onwards
  var i = 3
  while i * i <= n {
    while n % i == 0 {
      factors.append(i)
      n = n / i
      if factors.count % 1000 == 0 {
        await Task.yield()
      }
    }
    i += 2
    //print(i)
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

/// Optimized version using small primes and 6k±1 optimization
/// - Parameter number: The number to factorize
/// - Returns: Array of prime factors in ascending order
/// - Throws: PrimeFactorizationError if the number is invalid
@available(macOS 10.15, *)
public func primeFactorsOptimized(of number: Int) async throws -> [Int] {
  guard number > 1 else {
    throw PrimeFactorizationError.invalidNumber
  }

  var factors: [Int] = []
  var n = number
  let smallPrimes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
  for prime in smallPrimes {
    while n % prime == 0 {
      factors.append(prime)
      n = n / prime
    }
    if n == 1 { return factors }
  }
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
    if i % 10000 == 1 { //k WTF?
      await Task.yield()
    }
  }
  if n > 1 {
    factors.append(n)
  }
  return factors
}

/// Concurrent version for multiple numbers
/// - Parameter numbers: Array of numbers to factorize
/// - Returns: Dictionary mapping each number to its prime factors
/// - Throws: PrimeFactorizationError if any number is invalid
@available(macOS 10.15, *)
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
