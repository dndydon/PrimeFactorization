import Foundation

// MARK: - Error Types

/// Errors that can occur during prime factorization operations
public enum PrimeFactorizationError: Error, Equatable {
    /// The input value is invalid (e.g., negative or zero where positive is required)
    case invalidInput(String)
    /// The requested range is too large to process efficiently
    case rangeTooLarge(Int)
}

// MARK: - Configuration

/// Thread-safe configuration for prime factorization operations.
///
/// ```swift
/// PrimeFactorizationConfig.shared.maxPrimeRange = 50_000_000
/// ```
public final class PrimeFactorizationConfig: @unchecked Sendable {
    private let lock = NSLock()
    private var _maxPrimeRange: Int = 15_000_000

    /// Shared singleton instance
    public static let shared = PrimeFactorizationConfig()

    private init() {}

    /// Maximum range size for prime generation. Default is 15,000,000.
    ///
    /// This property is thread-safe and can be accessed from any context.
    public var maxPrimeRange: Int {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _maxPrimeRange
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _maxPrimeRange = newValue
        }
    }
}

// MARK: - Prime Factor Utilities

public extension Int {

    /// Returns the largest prime factor of the integer.
    ///
    /// - Returns: The largest prime factor, or `nil` if the number has no prime factors (<= 1).
    /// - Complexity: O(sqrt(n))
    ///
    /// ```swift
    /// 60.largestPrimeFactor  // Optional(5)
    /// 1.largestPrimeFactor   // nil
    /// ```
    var largestPrimeFactor: Int? {
        return self.primeFactors.max()
    }

    /// Returns the smallest prime factor of the integer.
    ///
    /// - Returns: The smallest prime factor, or `nil` if the number has no prime factors (<= 1).
    /// - Complexity: O(sqrt(n))
    ///
    /// ```swift
    /// 60.smallestPrimeFactor  // Optional(2)
    /// 1.smallestPrimeFactor   // nil
    /// ```
    var smallestPrimeFactor: Int? {
        return self.primeFactors.min()
    }
}

// MARK: - Prime Generation (6k±1 Method)

/// Maximum span for the jump-6 method
private let maxJump6Span = 100_000_000_000

/// Generates prime numbers in a range using the optimized 6k±1 method.
private func primesByJump6Method(from start: Int = 5, through end: Int = 500) -> [Int] {
    guard start <= end else { return [] }
    guard start >= 1 else { return [] }
    guard end >= 2 else { return [] }
    guard end - start <= maxJump6Span else { return [] }

    var primes: [Int] = []

    if start <= 2 && end >= 2 { primes.append(2) }
    if start <= 3 && end >= 3 { primes.append(3) }

    var cursor = startCursor(from: start)

    while cursor <= end && cursor + 2 < Int.max - 6 {
        [cursor, cursor + 2]
            .filter { $0.isPrime && $0 <= end }
            .forEach { primes.append($0) }
        cursor += 6
    }

    return primes
}

/// Finds the next 6k-1 cursor value equal to or above the given start value.
private func startCursor(from start: Int) -> Int {
    return start + (5 - start % 6 + 6) % 6
}

// MARK: - Prime Generation (Sieves)

/// Returns the largest integer whose square is <= `n`.
private func integerSquareRoot(_ n: Int) -> Int {
    guard n > 1 else { return max(n, 0) }
    var root = Int(Double(n).squareRoot())
    while root * root > n { root -= 1 }
    while true {
        let (square, overflow) = (root + 1).multipliedReportingOverflow(by: root + 1)
        if overflow || square > n { break }
        root += 1
    }
    return root
}

/// Returns all primes from 2 through `limit` using the Sieve of Eratosthenes.
func sieveOfEratosthenes(limit: Int) -> [Int] {
    guard limit >= 2 else { return [] }

    var isPrime = Array(repeating: true, count: limit + 1)
    isPrime[0] = false
    isPrime[1] = false

    var i = 2
    while i * i <= limit {
        if isPrime[i] {
            for j in stride(from: i * i, through: limit, by: i) {
                isPrime[j] = false
            }
        }
        i += 1
    }

    return isPrime.enumerated().compactMap { $0.element ? $0.offset : nil }
}

/// Returns all primes in `[start, end]` using a segmented Sieve of Eratosthenes.
///
/// Memory is bounded by the segment size, not the range size. Offsets into each
/// segment are used instead of absolute values so nothing overflows near `Int.max`.
private func primesBySegmentedSieve(from start: Int, through end: Int) -> [Int] {
    let low = max(start, 2)
    guard low <= end else { return [] }

    let basePrimes = sieveOfEratosthenes(limit: integerSquareRoot(end))
    let segmentSize = 1 << 18
    var primes: [Int] = []
    var segmentStart = low

    while true {
        let segmentEnd = segmentStart + min(segmentSize - 1, end - segmentStart)
        let count = segmentEnd - segmentStart + 1
        var isComposite = [Bool](repeating: false, count: count)

        for p in basePrimes {
            let square = p * p
            if square > segmentEnd { break }
            let remainder = segmentStart % p
            var index = max(square - segmentStart, remainder == 0 ? 0 : p - remainder)
            while index < count {
                isComposite[index] = true
                index += p
            }
        }

        for (offset, composite) in isComposite.enumerated() where !composite {
            primes.append(segmentStart + offset)
        }

        if segmentEnd == end { break }
        segmentStart = segmentEnd + 1
    }

    return primes
}

// MARK: - Public Prime Generation API

/// Generates an array of prime numbers in a specified range.
///
/// Uses a segmented Sieve of Eratosthenes when the range is at least as wide as
/// `sqrt(endIndex)`. Narrow ranges of very large numbers (e.g. near `Int.max`) use
/// 6k±1 trial division instead, since sieving would need primes up to `sqrt(endIndex)`.
///
/// - Parameters:
///   - startIndex: The lower bound of the range (inclusive). Must be positive. Default is 2.
///   - endIndex: The upper bound of the range (inclusive). Must be >= startIndex.
/// - Returns: An array of all prime numbers in the range [startIndex, endIndex].
/// - Throws: ``PrimeFactorizationError/invalidInput(_:)`` if arguments are invalid,
///           or ``PrimeFactorizationError/rangeTooLarge(_:)`` if the range is too large.
/// - Complexity: O(n log log n + sqrt(end)) for the sieve path, where n is the size of the range.
///
/// ```swift
/// let primes = try primeNumbers(from: 10, through: 30)
/// // [11, 13, 17, 19, 23, 29]
/// ```
public func primeNumbers(from startIndex: Int = 2, through endIndex: Int) throws -> [Int] {

    guard startIndex > 0 else {
        throw PrimeFactorizationError.invalidInput("startIndex must be > 0, got \(startIndex)")
    }

    guard startIndex <= endIndex else {
        throw PrimeFactorizationError.invalidInput("startIndex (\(startIndex)) must be <= endIndex (\(endIndex))")
    }

    guard endIndex - startIndex <= PrimeFactorizationConfig.shared.maxPrimeRange else {
        throw PrimeFactorizationError.rangeTooLarge(endIndex - startIndex)
    }

    if integerSquareRoot(endIndex) <= endIndex - startIndex {
        return primesBySegmentedSieve(from: startIndex, through: endIndex)
    }
    return primesByJump6Method(from: startIndex, through: endIndex)
}

// MARK: - Array Extensions

public extension Array where Element == Int {

    /// Returns a simple string representation of the array.
    ///
    /// ```swift
    /// [2, 2, 3, 5].simpleArrayDescription  // "[2, 2, 3, 5]"
    /// ```
    var simpleArrayDescription: String {
        "[" + self.map(String.init).joined(separator: ", ") + "]"
    }

    /// Returns a string representation of prime factorization with exponents.
    ///
    /// ```swift
    /// [2, 2, 3, 3, 3, 5].primeFactorizationString  // "2^2 × 3^3 × 5"
    /// ```
    var primeFactorizationString: String {
        let factorCounts = self.reduce(into: [:]) { counts, factor in
            counts[factor, default: 0] += 1
        }
        return factorCounts
            .sorted { $0.key < $1.key }
            .map { factor, count in
                count == 1 ? "\(factor)" : "\(factor)^\(count)"
            }
            .joined(separator: " × ")
    }
}
