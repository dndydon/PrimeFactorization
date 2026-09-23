import Foundation

// MARK: - PrimeFactorizable Protocol

/// A type that supports prime factorization, primality testing, and factor enumeration.
///
/// Conforming types get default implementations of `primeFactors`, `isPrime`, and `allFactors`
/// using generic arithmetic with overflow-safe loop bounds (`multipliedReportingOverflow`).
///
/// `Int`, `Int64`, and `UInt` override all three with a shared 64-bit engine: table-driven
/// trial division below 7,927², Miller-Rabin and Pollard-Brent rho above it. The members are
/// protocol requirements so those overrides are used even through a generic `T: PrimeFactorizable`.
public protocol PrimeFactorizable: FixedWidthInteger {
    init(_ value: Int)
    var primeFactors: [Self] { get }
    var isPrime: Bool { get }
    var allFactors: [Self] { get }
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

// MARK: - 64-bit Engine

/// Prime factorization and primality testing on `UInt64`, shared by `Int`, `Int64`, and `UInt`.
///
/// Values below ``tableCoverageLimit`` are handled entirely by trial division with the
/// `smallPrimes` table. Larger values use deterministic Miller-Rabin for primality and
/// Pollard-Brent rho to split composites, so even 19-digit semiprimes factor in milliseconds.
enum PrimeEngine {

    /// 7,927² — the square of the first prime past the table. Any value below this with no
    /// factor in the table is prime.
    static let tableCoverageLimit: UInt64 = 7927 * 7927

    /// Witnesses that make Miller-Rabin deterministic for every 64-bit value.
    private static let millerRabinBases: [UInt64] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]

    // MARK: Primality

    static func isPrime(_ n: UInt64) -> Bool {
        if n < 2 { return false }
        if n < tableCoverageLimit {
            for p in smallPrimes {
                let p = UInt64(p)
                if p * p > n { return true }
                if n % p == 0 { return false }
            }
            return true
        }
        for p in millerRabinBases where n % p == 0 { return false }
        return millerRabin(n)
    }

    private static func millerRabin(_ n: UInt64) -> Bool {
        let nMinusOne = n - 1
        let shift = nMinusOne.trailingZeroBitCount
        let d = nMinusOne >> shift

        witnessLoop: for a in millerRabinBases {
            var x = powMod(a, d, n)
            if x == 1 || x == nMinusOne { continue }
            for _ in 1..<shift {
                x = mulMod(x, x, n)
                if x == nMinusOne { continue witnessLoop }
            }
            return false
        }
        return true
    }

    // MARK: Factorization

    /// Returns the prime factors of `n` in ascending order, as `T`. Empty for `n < 2`.
    ///
    /// Building the result directly in the caller's type avoids a second array conversion.
    static func primeFactors<T: FixedWidthInteger>(_ value: UInt64, as type: T.Type) -> [T] {
        guard value > 1 else { return [] }

        var n = value
        var factors: [T] = []
        factors.reserveCapacity(32)

        let trailingZeros = n.trailingZeroBitCount
        if trailingZeros > 0 {
            factors.append(contentsOf: repeatElement(2, count: trailingZeros))
            n >>= trailingZeros
        }

        for p in smallPrimes.dropFirst() {
            let p = UInt64(p)
            if p * p > n { break }
            if n % p == 0 {
                repeat {
                    factors.append(T(truncatingIfNeeded: p))
                    n /= p
                } while n % p == 0
            }
        }

        if n > 1 {
            if n < tableCoverageLimit {
                factors.append(T(truncatingIfNeeded: n))
            } else {
                var large: [UInt64] = []
                splitLargeFactor(n, into: &large)
                factors.append(contentsOf: large.sorted().lazy.map { T(truncatingIfNeeded: $0) })
            }
        }

        return factors
    }

    /// Returns all divisors of `n` in ascending order, built from its prime factorization.
    static func allFactors<T: FixedWidthInteger>(_ n: UInt64, as type: T.Type) -> [T] {
        guard n > 0 else { return [] }

        var divisors: [T] = [1]
        let primes = primeFactors(n, as: T.self)
        var index = 0
        while index < primes.count {
            let p = primes[index]
            var exponent = 0
            while index < primes.count && primes[index] == p {
                exponent += 1
                index += 1
            }
            let base = divisors
            var power: T = 1
            for _ in 0..<exponent {
                power *= p
                divisors.append(contentsOf: base.map { $0 * power })
            }
        }
        return divisors.sorted()
    }

    /// Appends the prime factors of `n` (which has no factor in the table) to `factors`, unordered.
    private static func splitLargeFactor(_ n: UInt64, into factors: inout [UInt64]) {
        if isPrime(n) {
            factors.append(n)
            return
        }
        let divisor = pollardBrent(n)
        splitLargeFactor(divisor, into: &factors)
        splitLargeFactor(n / divisor, into: &factors)
    }

    /// Returns a nontrivial divisor of the composite `n` using Brent's variant of Pollard's rho.
    private static func pollardBrent(_ n: UInt64) -> UInt64 {
        let batchSize: UInt64 = 128
        var c: UInt64 = 1

        while true {
            let step = { (v: UInt64) -> UInt64 in
                let square = mulMod(v, v, n)
                return square >= n - c ? square - (n - c) : square + c
            }

            var y: UInt64 = 2
            var x: UInt64 = 2
            var saved: UInt64 = 2
            var product: UInt64 = 1
            var divisor: UInt64 = 1
            var cycleLength: UInt64 = 1

            repeat {
                x = y
                for _ in 0..<cycleLength { y = step(y) }
                var steps: UInt64 = 0
                repeat {
                    saved = y
                    for _ in 0..<min(batchSize, cycleLength - steps) {
                        y = step(y)
                        product = mulMod(product, x > y ? x - y : y - x, n)
                    }
                    divisor = gcd(product, n)
                    steps += batchSize
                } while steps < cycleLength && divisor == 1
                cycleLength <<= 1
            } while divisor == 1

            if divisor == n {
                // The batch overshot; retrace one step at a time from the saved point.
                repeat {
                    saved = step(saved)
                    divisor = gcd(x > saved ? x - saved : saved - x, n)
                } while divisor == 1
            }

            if divisor != n { return divisor }
            c += 1
        }
    }

    // MARK: Modular Arithmetic

    @inline(__always)
    private static func mulMod(_ a: UInt64, _ b: UInt64, _ m: UInt64) -> UInt64 {
        m.dividingFullWidth(a.multipliedFullWidth(by: b)).remainder
    }

    private static func powMod(_ base: UInt64, _ exponent: UInt64, _ m: UInt64) -> UInt64 {
        var result: UInt64 = 1
        var b = base % m
        var e = exponent
        while e > 0 {
            if e & 1 == 1 { result = mulMod(result, b, m) }
            b = mulMod(b, b, m)
            e >>= 1
        }
        return result
    }

    private static func gcd(_ a: UInt64, _ b: UInt64) -> UInt64 {
        var a = a
        var b = b
        while b != 0 { (a, b) = (b, a % b) }
        return a
    }
}

// MARK: - Int, Int64, UInt Overrides

public extension Int {

    /// Returns the prime factors of the integer in ascending order.
    ///
    /// Uses trial division with a pre-computed table of 1,000 small primes, then
    /// Miller-Rabin and Pollard-Brent rho for any remaining cofactor above 7,927².
    ///
    /// - Returns: An array of prime factors. Returns an empty array for values <= 1.
    ///
    /// ```swift
    /// 60.primeFactors   // [2, 2, 3, 5]
    /// 97.primeFactors   // [97]
    /// ```
    var primeFactors: [Int] {
        self > 1 ? PrimeEngine.primeFactors(UInt64(self), as: Int.self) : []
    }

    /// Returns `true` if the integer is a prime number.
    ///
    /// Uses the small primes table below 7,927² and deterministic Miller-Rabin above it.
    ///
    /// ```swift
    /// 7.isPrime   // true
    /// 10.isPrime  // false
    /// ```
    var isPrime: Bool {
        self > 1 && PrimeEngine.isPrime(UInt64(self))
    }

    /// Returns all divisors of the integer in ascending order, built from its prime factorization.
    ///
    /// ```swift
    /// 60.allFactors  // [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60]
    /// ```
    var allFactors: [Int] {
        self > 0 ? PrimeEngine.allFactors(UInt64(self), as: Int.self) : []
    }
}

public extension Int64 {

    /// Returns the prime factors in ascending order, using the shared 64-bit engine.
    var primeFactors: [Int64] {
        self > 1 ? PrimeEngine.primeFactors(UInt64(self), as: Int64.self) : []
    }

    /// Returns `true` if the value is prime, using the shared 64-bit engine.
    var isPrime: Bool {
        self > 1 && PrimeEngine.isPrime(UInt64(self))
    }

    /// Returns all divisors in ascending order, using the shared 64-bit engine.
    var allFactors: [Int64] {
        self > 0 ? PrimeEngine.allFactors(UInt64(self), as: Int64.self) : []
    }
}

public extension UInt {

    /// Returns the prime factors in ascending order, using the shared 64-bit engine.
    var primeFactors: [UInt] {
        PrimeEngine.primeFactors(UInt64(self), as: UInt.self)
    }

    /// Returns `true` if the value is prime, using the shared 64-bit engine.
    var isPrime: Bool {
        PrimeEngine.isPrime(UInt64(self))
    }

    /// Returns all divisors in ascending order, using the shared 64-bit engine.
    var allFactors: [UInt] {
        PrimeEngine.allFactors(UInt64(self), as: UInt.self)
    }
}
