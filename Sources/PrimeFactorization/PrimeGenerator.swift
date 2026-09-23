import Foundation

// MARK: - PrimeGenerator Actor

/// An actor that provides cached prime factorization and prime generation.
///
/// `PrimeGenerator` is useful when factorizing many numbers repeatedly, as it caches
/// results for fast subsequent lookups. It also provides a Sieve of Eratosthenes
/// implementation for efficiently generating all primes up to a limit.
///
/// ```swift
/// let generator = PrimeGenerator()
/// let factors = await generator.primeFactors(of: 5040)
/// let primes = await generator.primes(upTo: 1000)
/// ```
@available(iOS 13.0, macOS 10.15, *)
public actor PrimeGenerator {
    private(set) var cache: [Int: [Int]] = [:]
    let maxCacheSize = 10000

    /// Cached keys in insertion order, used as a ring buffer for FIFO eviction.
    private var insertionOrder: [Int] = []
    private var nextEvictionIndex = 0

    public init() {}

    /// Returns the prime factors of a number, using a cache for repeated lookups.
    ///
    /// - Parameter number: The number to factorize.
    /// - Returns: An array of prime factors in ascending order. Empty for values <= 1.
    public func primeFactors(of number: Int) async -> [Int] {
        if let cached = cache[number] {
            return cached
        }

        let factors = await Task.detached {
            return number.primeFactors
        }.value

        // Another call may have cached this number while we were suspended.
        if let cached = cache[number] {
            return cached
        }

        store(factors, for: number)
        return factors
    }

    /// Caches `factors`, evicting only the oldest entry when the cache is full.
    private func store(_ factors: [Int], for number: Int) {
        if insertionOrder.count < maxCacheSize {
            insertionOrder.append(number)
        } else {
            cache.removeValue(forKey: insertionOrder[nextEvictionIndex])
            insertionOrder[nextEvictionIndex] = number
            nextEvictionIndex = (nextEvictionIndex + 1) % maxCacheSize
        }
        cache[number] = factors
    }

    /// Generates all prime numbers up to the given limit.
    ///
    /// For limits within the pre-computed small primes table (up to 7,919), returns
    /// a slice of the table instantly. For larger limits, uses the Sieve of Eratosthenes.
    ///
    /// - Parameter limit: The upper bound (inclusive).
    /// - Returns: An array of all primes from 2 through `limit`.
    public func primes(upTo limit: Int) async -> [Int] {
        // Fast path: return slice of pre-computed table
        if let lastPrime = smallPrimes.last, limit <= lastPrime {
            return smallPrimes.prefix(while: { $0 <= limit })
        }

        // The sieve is a nonisolated free function, so it runs off the actor
        // and does not block cache lookups while it works. The segmented sieve
        // keeps memory bounded regardless of `limit`.
        return await Task.detached {
            primesBySegmentedSieve(from: 2, through: limit)
        }.value
    }
}

// MARK: - Concurrent Batch Factorization

/// Computes prime factors for multiple numbers concurrently.
///
/// Uses structured concurrency to factorize multiple numbers in parallel,
/// which can significantly speed up batch processing.
///
/// - Parameter numbers: An array of numbers to factorize. All must be > 1.
/// - Returns: A dictionary mapping each number to its prime factors.
/// - Throws: ``PrimeFactorizationError/invalidInput(_:)`` if any number is <= 1.
///
/// ```swift
/// let results = try await primeFactorsConcurrent(of: [12, 18, 24])
/// // [12: [2, 2, 3], 18: [2, 3, 3], 24: [2, 2, 2, 3]]
/// ```
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func primeFactorsConcurrent(of numbers: [Int]) async throws -> [Int: [Int]] {
    for number in numbers {
        guard number > 1 else {
            throw PrimeFactorizationError.invalidInput("All numbers must be greater than 1, got \(number)")
        }
    }

    return await withTaskGroup(of: (Int, [Int]).self) { group in
        var results: [Int: [Int]] = [:]

        for number in numbers {
            group.addTask {
                return (number, number.primeFactors)
            }
        }

        for await (number, factors) in group {
            results[number] = factors
        }

        return results
    }
}
