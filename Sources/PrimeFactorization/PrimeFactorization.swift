// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

//: Prime Factorization & All Factorization


/// Given a positive integer, find all the prime numbers up to it
/// - Parameter limit: up to Int.max
/// - Returns: array of prime numbers less than limit
public func primeNumbersBelow(_ limit: Int) -> [Int] {
  var result: [Int] = []
  for val in stride(from: 2, to: limit, by: 1) {
    if val.isPrime { result.append(val) }
  }
  return result
}

/// Array of prime integer factors - property on Int
///
/// - property: primeFactors.
///
/// - returns: Array of integers that are the prime factors of self.
///
public extension Int {
  var primeFactors: [Int] {
    return primeFactorsOf(self)
  }
}

public extension Int {
  /// Prime Factors of a given integer
  ///
  /// - Parameter number: given integer
  /// 
  /// - Returns: array of integers
  func primeFactorsOf(_ number: Int) -> [Int] {
    guard number > 3 else { return [number] }
    // upper bound for exiting the for loop below
    let maxDivisor = Int(sqrt(Double(number)))
    if maxDivisor < 5 {
      for littleCheck in stride(from: 2, to: 5, by: 1) {
        //print("littleCheck", littleCheck)
        if number % littleCheck == 0 {
          var resultFactors = [littleCheck]
          resultFactors.append(contentsOf: (primeFactorsOf(number / littleCheck)))
          return resultFactors
        }
      }
    } else {
        for jump6Value in stride(from: 5, through: maxDivisor, by: 6) {
          print("maxDivisor: \(maxDivisor)")
          for check in [2,3,4,jump6Value, jump6Value + 2] {
            print("checking \(check)")
            if number % check == 0 {
              var resultFactors = [check]
              resultFactors.append(contentsOf: (primeFactorsOf(number / check)))
              return resultFactors
            }
          }
        }
      }
    return [number]
    }
}


/// Boolean property on Int
///
/// - property: isPrime. Renamed to remove it from service (see new one below)
///
/// - returns: Bool whether self is prime.
///
public extension Int {
  var OLDisPrime: Bool {
    guard self >= 2     else { return false }
    guard self != 2     else { return true  }
    guard self % 2 != 0 else { return false }
    // this checks all odd numbers up to the maximum possible divisor
    return !stride(from: 3, through: Int(sqrt(Double(self))), by: 2).contains { self % $0 == 0 }
  }
}

/// Given an integer, return true it is prime, or not.
///
/// - property: isPrime.
///
/// - returns: Bool whether self is prime.
///
public func isPrime(_ n: Int) -> Bool {
  return n.isPrime
}


///
/// A more efficient version of checkPrime() uses the fact that prime numbers,
/// other than 2 and 3 can all be written as 6X - 1 or 6X + 1:
/// See: https://primes.utm.edu/notes/faq/six.html
/// Source: https://stackoverflow.com/questions/53022927/uilabel-doesnt-refresh-at-every-calculation/53023939#53023939
/// Change this into an extension on Int, like above isPrime [donee]
/// /// - note: Do a performance comparison between this and OLDisPrime (above)
///
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

        // instead of just checking all odd numbers... up to maxDivisor
        // start at 5 (after handling 2 & 3, above), jump by 6... to 11, 17, 23, 29, 35...
        // check self (which is odd) and the next odd number (2 up) ??
        // bail if either divides evenly, otherwise keep going up 6
        var divisor = 5
        while (divisor <= maxDivisor) {
          if self % divisor == 0 || self % (divisor + 2) == 0 {
            //print(self, divisor)
            return false
          }
          divisor += 6
        }

        return true
    }
  }
}

/// Use our self.primeFactors to return the largest or smallest Prime Factor of self
/// We are guaranteed that primeFactors returns at least one Int, so we can force unwrap
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

// --------- Experimental ---------- //

/*
protocol Factorable {
  var value: Int { get set }
  var allPrimesLessThan: [Int] { get }
  var allFactors: [Int] { get }
}

class DSNumber: Factorable {
  var value: Int

  private(set) lazy var allPrimesLessThan: [Int] = {
    return [2,3,7]  // 42
  }()

  let allFactors: [Int]

  init(allFactors: [Int]) {
    self.allFactors = allFactors
  }

  lazy var averageFactor: Double = {
    return allFactors.reduce(0.0, { total, factor in
      return total + Double (factor)
    }) / Double(allFactors.count)
  }()
}
*/
