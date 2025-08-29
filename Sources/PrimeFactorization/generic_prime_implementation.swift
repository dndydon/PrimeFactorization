import Foundation

// MARK: - Generic Prime Operations Protocol
public protocol PrimeFactorizable: BinaryInteger, Comparable {
  init(_ value: Int)
  var doubleValue: Double { get }
}

extension Int: PrimeFactorizable {
  public var doubleValue: Double { Double(self) }
}

extension Int64: PrimeFactorizable {
  public var doubleValue: Double { Double(self) }
}

extension UInt: PrimeFactorizable {
  public var doubleValue: Double { Double(self) }
}

// MARK: - Generic Prime Extensions
public extension PrimeFactorizable {
  /// Returns prime factors using generic implementation
  var primeFactors: [Self] {
    return genericPrimeFactorsOf(self)
  }

  /// Generic prime factorization with overflow protection
  private func genericPrimeFactorsOf(_ number: Self) -> [Self] {
    guard number > 1 else { return [] }

    var n = number
    var factors: [Self] = []

    let two = Self(2)
    let three = Self(3)

    // Handle factor 2
    while n % two == 0 {
      factors.append(two)
      n /= two
    }

    // Handle factor 3
    while n % three == 0 {
      factors.append(three)
      n /= three
    }

    // Check 6k±1 factors with overflow protection
    var divisor = Self(5)
    while divisor <= n / divisor { // Prevents overflow
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

  /// Generic prime checking with overflow protection
  var isPrime: Bool {
    if self <= 1 { return false }
    if self <= 3 { return true }
    if self % 2 == 0 || self % 3 == 0 { return false }

    var divisor = Self(5)
    while divisor <= self / divisor { // Overflow protection
      if self % divisor == 0 || self % (divisor + Self(2)) == 0 {
        return false
      }
      divisor += Self(6)
    }
    return true
  }
}

// MARK: - Performance Optimized Implementations
public extension Int {
  /// High-performance prime factorization for Int specifically
  var fastPrimeFactors: [Int] {
    guard self > 1 else { return [] }

    var n = self
    var factors: [Int] = []
    factors.reserveCapacity(32) // Most numbers have few factors

    // Optimized for CPU cache and branch prediction
    let trailingZeros = n.trailingZeroBitCount
    if trailingZeros > 0 {
      factors.append(contentsOf: Array(repeating: 2, count: trailingZeros))
      n >>= trailingZeros // Equivalent to dividing by 2^trailingZeros
    }

    // Handle factor 3
    while n % 3 == 0 {
      factors.append(3)
      n /= 3
    }

    // 6k±1 optimization with unrolled loop
    var divisor = 5
    while divisor * divisor <= n {
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
}

// MARK: - Async Prime Generation for Large Numbers
@available(iOS 13.0, macOS 10.15, *)
public actor PrimeGenerator {
  private var cache: [Int: [Int]] = [:]
  private let maxCacheSize = 10000

  public init() {}

  /// Async prime factorization with caching
  public func primeFactors(of number: Int) async -> [Int] {
    if let cached = cache[number] {
      return cached
    }

    let factors = await Task.detached {
      return number.fastPrimeFactors
    }.value

    // Cache management
    if cache.count >= maxCacheSize {
      cache.removeAll(keepingCapacity: true)
    }
    cache[number] = factors

    return factors
  }

  /// Generate primes up to limit asynchronously
  public func primes(upTo limit: Int) async -> [Int] {
    return await Task.detached {
      await self.sieveOfEratosthenes(limit: limit)
    }.value
  }

  private func sieveOfEratosthenes(limit: Int) -> [Int] {
    guard limit >= 2 else { return [] }

    var isPrime = Array(repeating: true, count: limit + 1)
    isPrime[0] = false
    isPrime[1] = false

    let sqrtLimit = Int(Double(limit).squareRoot())

    for i in 2...sqrtLimit {
      if isPrime[i] {
        // Mark multiples as composite
        for j in stride(from: i * i, through: limit, by: i) {
          isPrime[j] = false
        }
      }
    }

    return isPrime.enumerated().compactMap { $0.element ? $0.offset : nil }
  }
}



// MARK: - SwiftUI Integration Helpers
#if canImport(SwiftUI)
import SwiftUI

@available(macOS 12.0, iOS 15.0, *)
public extension View {
  /// Modifier to display prime factorization asynchronously
  func primeFactorization(of number: Binding<Int>) -> some View {
    self.task(id: number.wrappedValue) {
      // Perform expensive prime factorization off main thread
      let generator = PrimeGenerator()
      let _ = await generator.primeFactors(of: number.wrappedValue)
      // Update UI on main thread
      await MainActor.run {
        // Update your @State property here
      }
    }
  }
}
#endif
