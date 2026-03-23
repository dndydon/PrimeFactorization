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
    private var cache: [Int: [Int]] = [:]
    private let maxCacheSize = 10000

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

        if cache.count >= maxCacheSize {
            cache.removeAll(keepingCapacity: true)
        }
        cache[number] = factors

        return factors
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
                for j in stride(from: i * i, through: limit, by: i) {
                    isPrime[j] = false
                }
            }
        }

        return isPrime.enumerated().compactMap { $0.element ? $0.offset : nil }
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
