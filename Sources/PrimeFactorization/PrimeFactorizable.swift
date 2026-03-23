import Foundation

// MARK: - PrimeFactorizable Protocol

/// A type that supports prime factorization, primality testing, and factor enumeration.
///
/// Conforming types get default implementations of `primeFactors`, `isPrime`, and `allFactors`
/// using generic arithmetic with overflow-safe loop bounds (`multipliedReportingOverflow`).
///
/// `Int` provides optimized overrides using bit operations and branch-optimized loops.
/// In release builds (`-O`), the compiler specializes generic code for concrete types,
/// so performance is comparable across all conforming types.
public protocol PrimeFactorizable: FixedWidthInteger {
    init(_ value: Int)
}

// MARK: - Conformances

extension Int: PrimeFactorizable {}
extension Int64: PrimeFactorizable {}
extension UInt: PrimeFactorizable {}

// MARK: - Generic Default Implementations

public extension PrimeFactorizable {

    /// Returns the prime factors of the value in ascending order.
    ///
    /// - Returns: An array of prime factors. Returns an empty array for values <= 1.
    /// - Complexity: O(sqrt(n))
    ///
    /// ```swift
    /// Int64(60).primeFactors  // [2, 2, 3, 5]
    /// UInt(97).primeFactors   // [97]
    /// ```
    var primeFactors: [Self] {
        guard self > 1 else { return [] }

        var n = self
        var factors: [Self] = []

        let two = Self(2)
        let three = Self(3)

        while n % two == 0 {
            factors.append(two)
            n /= two
        }

        while n % three == 0 {
            factors.append(three)
            n /= three
        }

        var divisor = Self(5)
        while true {
            let (square, overflow) = divisor.multipliedReportingOverflow(by: divisor)
            if overflow || square > n { break }

            let nextCandidate = divisor + Self(2)

            while n % divisor == 0 {
                factors.append(divisor)
                n /= divisor
            }

            while n % nextCandidate == 0 {
                factors.append(nextCandidate)
                n /= nextCandidate
            }

            divisor += Self(6)
        }

        if n > 1 {
            factors.append(n)
        }

        return factors
    }

    /// Returns `true` if the value is a prime number.
    ///
    /// - Complexity: O(sqrt(n))
    ///
    /// ```swift
    /// Int64(97).isPrime  // true
    /// UInt(100).isPrime  // false
    /// ```
    var isPrime: Bool {
        if self <= 1 { return false }
        if self <= 3 { return true }
        if self % 2 == 0 || self % 3 == 0 { return false }

        var divisor = Self(5)
        while true {
            let (square, overflow) = divisor.multipliedReportingOverflow(by: divisor)
            if overflow || square > self { break }
            if self % divisor == 0 || self % (divisor + Self(2)) == 0 {
                return false
            }
            divisor += Self(6)
        }
        return true
    }

    /// Returns all factors (divisors) of the value in ascending order.
    ///
    /// - Returns: An array of all divisors. Returns an empty array for values <= 0, or `[1]` for 1.
    /// - Complexity: O(sqrt(n))
    ///
    /// ```swift
    /// 60.allFactors  // [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60]
    /// ```
    var allFactors: [Self] {
        guard self > 0 else { return [] }
        if self == 1 { return [1] }

        var low: [Self] = []
        var high: [Self] = []

        var i = Self(1)
        while true {
            let (square, overflow) = i.multipliedReportingOverflow(by: i)
            if overflow || square > self { break }

            if self % i == 0 {
                low.append(i)
                let complement = self / i
                if i != complement {
                    high.append(complement)
                }
            }
            i += 1
        }

        return low + high.reversed()
    }
}

// MARK: - Int-Specific Optimized Overrides

public extension Int {

    /// Returns the prime factors of the integer in ascending order.
    ///
    /// This `Int`-specific override uses a pre-computed table of 1,000 small primes
    /// for trial division (covering numbers up to ~62.7 million completely), then falls
    /// back to the 6k±1 method for larger divisors. Also uses `trailingZeroBitCount`
    /// for fast power-of-2 extraction.
    ///
    /// - Returns: An array of prime factors. Returns an empty array for values <= 1.
    /// - Complexity: O(sqrt(n))
    ///
    /// ```swift
    /// 60.primeFactors   // [2, 2, 3, 5]
    /// 97.primeFactors   // [97]
    /// ```
    var primeFactors: [Int] {
        guard self > 1 else { return [] }

        var n = self
        var factors: [Int] = []
        factors.reserveCapacity(32)

        // Fast path for powers of 2 using bit operations
        let trailingZeros = n.trailingZeroBitCount
        if trailingZeros > 0 {
            factors.append(contentsOf: repeatElement(2, count: trailingZeros))
            n >>= trailingZeros
        }

        // Trial division using pre-computed primes table (skip index 0 = prime 2, already handled)
        for i in 1..<smallPrimes.count {
            let p = smallPrimes[i]
            if p * p > n { break }
            if n % p == 0 {
                repeat {
                    factors.append(p)
                    n /= p
                } while n % p == 0
            }
        }

        // Continue with 6k±1 for divisors beyond the table
        let lastTablePrime = smallPrimes.last!
        // Start from the next 6k-1 candidate after the last table prime
        var divisor = lastTablePrime + (6 - lastTablePrime % 6) + 5
        // Ensure we don't re-test primes already in the table
        if divisor <= lastTablePrime { divisor += 6 }

        while true {
            let (square, overflow) = divisor.multipliedReportingOverflow(by: divisor)
            if overflow || square > n { break }

            if n % divisor == 0 {
                repeat {
                    factors.append(divisor)
                    n /= divisor
                } while n % divisor == 0
            }

            let candidate = divisor + 2
            if n % candidate == 0 {
                repeat {
                    factors.append(candidate)
                    n /= candidate
                } while n % candidate == 0
            }

            divisor += 6
        }

        if n > 1 {
            factors.append(n)
        }

        return factors
    }

    /// Returns `true` if the integer is a prime number.
    ///
    /// This `Int`-specific override uses the pre-computed small primes table for
    /// trial division, then falls back to 6k±1 for larger divisors.
    ///
    /// - Complexity: O(sqrt(n))
    ///
    /// ```swift
    /// 7.isPrime   // true
    /// 10.isPrime  // false
    /// ```
    var isPrime: Bool {
        if self <= 1 { return false }
        if self <= 3 { return true }
        if self & 1 == 0 { return false }

        // Check divisibility against pre-computed primes table
        for i in 1..<smallPrimes.count {
            let p = smallPrimes[i]
            if p * p > self { return true }
            if self % p == 0 { return false }
        }

        // Continue with 6k±1 for divisors beyond the table
        let lastTablePrime = smallPrimes.last!
        var divisor = lastTablePrime + (6 - lastTablePrime % 6) + 5
        if divisor <= lastTablePrime { divisor += 6 }

        while true {
            let (square, overflow) = divisor.multipliedReportingOverflow(by: divisor)
            if overflow || square > self { break }
            if self % divisor == 0 || self % (divisor + 2) == 0 {
                return false
            }
            divisor += 6
        }
        return true
    }
}
