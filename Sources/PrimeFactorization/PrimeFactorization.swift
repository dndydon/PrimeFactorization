// The Swift Programming Language
// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/

import Foundation

//: Prime Factorization & All Factorization


/// Array of prime integer factors - property on Int
///
/// - property: primeFactors.
///
/// - returns: Array of integers that are the prime factors of self.
///
public extension Int {
  var primeFactors: [Int] {
    //return newPrimeFactorsOf(self)  EXPERIMENTAL  why so slow??
    return primeFactorsOf(self)
  }
}

public extension Int {
  /// Prime Factors of a given integer
  ///
  /// - Parameter number: the given integer
  ///
  /// - Returns: array of integers
  /// See: https://primes.utm.edu/notes/faq/six.html
  /// Source: https://stackoverflow.com/questions/53022927/uilabel-doesnt-refresh-at-every-calculation/53023939#53023939
  /// - Note: This needs rewriting. Two loops?? Branches??
  ///          Recursive. written as 6X - 1 or 6X + 1
  func primeFactorsOf(_ number: Int) -> [Int] {

    // takes care of negative numbers, 0, 1, 2, 3 and just returns the input as array
    // negative numbers, zero, and one don't have prime factors, for various reasons
    // 2 and 3 are their prime factors. Skip this if number is 4...
    guard number > 3 else { return [number] }


    // upper bound for efficiently exiting the loops(!) and branching
    let maxDivisor = Int(sqrt(Double(number)))

    let jumpBy = (maxDivisor < 5) ? 1 : 6

    var resultFactors = [Int]()

    // if number < 25
    if maxDivisor < 5 {
      // for littleDivisor in stride(from: 2, through: maxDivisor, by: jumpBy) {
      for littleDivisor in [2, 3] {
        if number % littleDivisor == 0 {
          resultFactors = [littleDivisor]
          resultFactors.append(contentsOf: (primeFactorsOf(number / littleDivisor)))
          return resultFactors
        }
      }
    }

    for jumpDivisor in stride(from: 5, through: maxDivisor, by: jumpBy) {
      for bigDivisor in [2, 3, jumpDivisor, jumpDivisor + 2] {
        if number % bigDivisor == 0 {
          resultFactors = [bigDivisor]
          resultFactors.append(contentsOf: (primeFactorsOf(number / bigDivisor)))
          return resultFactors
        }
      }
    }
    resultFactors = [number]
    return resultFactors  //[number]
  }


  /// Prime Factors of a given integer
  ///
  /// - Parameter number: the given integer
  ///
  /// - Returns: array of integers (prime factors) in low to high order
  ///
  /// The prime factors of a number are:
  /// 1. factors (evenly divide that number and multiply to that number)
  /// 2. returned as a short sequence (not a set) of prime numbers chosen from
  /// 3. the set of primes below the square root of that number
  func newPrimeFactorsOf(_ number: Int) -> [Int] {

    // upper bound for prime factors
    let maxPrime = Int(sqrt(Double(number)))

    // memoize this set? // assuming any order?
    let potentialPrimes = primeNumbersUpTo(maxPrime) // this could be a lookup

    var resultFactors = [Int]()

    for checkDivisor in potentialPrimes {
      if number % checkDivisor == 0 {
        resultFactors = [checkDivisor]
        resultFactors.append(contentsOf: (newPrimeFactorsOf(number / checkDivisor)))
        return resultFactors
      }
    }

    resultFactors = [number]
    return resultFactors
  }

}


/// Boolean property on Int
///
/// - computed property: isPrime2. (see alternate implementation below)
///
/// - returns: Bool whether self is prime.
///
/// isPrime2 uses the fact that all prime numbers,
/// other than 2 and 3 can all be written as mod 6X - 1 or mod 6X + 1
/// See: https://primes.utm.edu/notes/faq/six.html
/// Source: https://stackoverflow.com/questions/53022927/uilabel-doesnt-refresh-at-every-calculation/53023939#53023939
/// Tests show this is approx 2x to 10x slower than .isPrime
public extension Int {
  var isPrime2: Bool {

    guard self >= 2 else { return false } // negative*, 0, 1 just returns false
    if self < 4       { return true }
    if self % 2 == 0  { return false }
    if self % 3 == 0  { return false }
    let maxDivisor = Int(sqrt(Double(self))) // divisor upper bound for self
    let jumpBy = (maxDivisor < 5) ? 2 : 6    // jump by 2 below 5 (25), jump by 6 at 25+
    for jumpDivisor in stride(from: 5, through: maxDivisor, by: jumpBy) {
      for check in [jumpDivisor, jumpDivisor + 2] {
        if self % check == 0 {
          return false
        }
      }
    }
    return true // never hit
  }
}


/// Boolean property on Int
///
/// - computed property: isPrime. (see alternate implementation above)
///
/// - returns: Bool whether self is prime.
///
/// This (faster) version of isPrime uses the fact that all prime numbers,
/// other than 2 and 3 can all be written as 6X - 1 or 6X + 1:
/// See: https://primes.utm.edu/notes/faq/six.html
/// Source: https://stackoverflow.com/questions/53022927/uilabel-doesnt-refresh-at-every-calculation/53023939#53023939
///
/// Tests show this is approx 2x to 10x faster than .isPrime2
public extension Int {
  var isPrime: Bool {
    switch self {
      case ...1:  // negative numbers, zero, and one are not prime, for various reasons
        return false
      case 2...3:
        return true
      default:    // even numbers and mod 3 numbers are not prime
        if self % 2 == 0 || self % 3 == 0 {
          return false
        }

        // upper bound for exiting the while loop below
        let maxDivisor = Int(sqrt(Double(self)))

        // instead of just checking ALL odd numbers... up to maxDivisor
        // start at divisor = 5 (after handling 2 & 3), jump by 6... to 11, 17, 23, 29, 35...
        // check self % divisor (which is odd) and self % divisor+2 (the next odd)
        // return false (not prime) if either divisor divides evenly, otherwise keep going up 6
        var divisor = 5
        while (divisor <= maxDivisor) {
          //print(" checking divisors:", divisor, divisor+2)
          if self % divisor == 0 || self % (divisor + 2) == 0 {
            return false
          }
          divisor += 6
        }
        return true
    }
  }
}


/// Use our self.primeFactors to return the max or min Prime Factor of self
/// We are guaranteed primeFactors returns at least one Int, so we can force unwrap
public extension Int {
  var largestPrime: Int {
    return self.primeFactors.max()!
  }

  var smallestPrime: Int {
    return self.primeFactors.min()!
  }
}

/// https://stackoverflow.com/questions/45445699/most-efficient-way-to-find-all-the-factors-of-a-number
public func allFactors(of n: Int) -> [Int] {
  precondition(n > 0, "n must be positive")
  let sqrtn = Int(Double(n).squareRoot()) // Int(sqrt(Double(n)))
  var factors: [Int] = []
  factors.reserveCapacity(2 * sqrtn)
  for i in 1...sqrtn {
    if n % i == 0 {
      factors.append(i)
    }
  }
  var j = factors.count - 1
  if factors[j] * factors[j] == n {
    j -= 1
  }
  while j >= 0 {
    factors.append(n / factors[j])
    j -= 1
  }
  return factors
}

/// Given a positive integer, find all the prime numbers up to it
///
/// - Parameter integer: up to Int.max, but set a maxValue for performance
///
/// - Returns: array of all prime numbers less than or equal to limit
///             NOT the prime factors of limit
///
/// - Notes: this should be memoized OR leverage a file-based lookup for large numbers
///            it is essentially a dictionary
///
public func primeNumbersUpTo(_ integer: Int) -> [Int] {
  var result: [Int] = []
  let maxValue = 1_000_000  // above this takes too much time
  switch integer {
    case ..<2:
      break
    case 2:
      return [2]  // 2 is the smallest integer with prime factors
    case 3...maxValue:
      result.append(2)

      // all primes above 2 are odd, start at 3 and jump by 2
      for val in stride(from: 3, through: integer, by: 2) {
        if val.isPrime { result.append(val) }
      }
    default: // don't compute primes above 1_000_000
      print("\(integer) is too big for primeNumbersBelow(Int)")
  }
  return result
}
