import Testing
@testable import PrimeFactorization

@Suite("PrimeGenerator and primeFactorsConcurrent")
struct PrimeGeneratorTests {

    // MARK: - Cached Factorization

    @Test(arguments: [(0, []), (1, []), (60, [2, 2, 3, 5]), (97, [97])] as [(Int, [Int])])
    func primeFactors(n: Int, expected: [Int]) async {
        let generator = PrimeGenerator()
        #expect(await generator.primeFactors(of: n) == expected)
    }

    @Test func cacheHitReturnsSameResult() async {
        let generator = PrimeGenerator()
        let first = await generator.primeFactors(of: 60)
        let second = await generator.primeFactors(of: 60)
        #expect(first == [2, 2, 3, 5])
        #expect(second == first)
        #expect(await generator.cache.count == 1)
    }

    /// maxCacheSize is 10,000; inserting 10,001 distinct numbers evicts only the oldest entry.
    @Test func fifoEviction() async {
        let generator = PrimeGenerator()
        for n in 2...10_002 {
            _ = await generator.primeFactors(of: n)
        }
        let cache = await generator.cache
        #expect(cache.count == 10_000)
        #expect(cache[2] == nil)
        #expect(cache[3] == [3])
        #expect(cache[10_002] == [2, 3, 1667])
        #expect(await generator.primeFactors(of: 60) == [2, 2, 3, 5])
    }

    @Test func concurrentRequestsForSameNumber() async {
        let generator = PrimeGenerator()
        await withTaskGroup(of: [Int].self) { group in
            for _ in 0..<10 {
                group.addTask { await generator.primeFactors(of: 5040) }
            }
            for await result in group {
                #expect(result == [2, 2, 2, 2, 3, 3, 5, 7])
            }
        }
        #expect(await generator.cache.count == 1)
    }

    // MARK: - primes(upTo:)

    @Test func primesFromTable() async {
        let generator = PrimeGenerator()
        #expect(await generator.primes(upTo: 30) == [2, 3, 5, 7, 11, 13, 17, 19, 23, 29])
        let upTo1000 = await generator.primes(upTo: 1000)
        #expect(upTo1000.count == 168)
        #expect(upTo1000.last == 997)
    }

    @Test func primesBelowTwo() async {
        let generator = PrimeGenerator()
        #expect(await generator.primes(upTo: 1) == [])
        #expect(await generator.primes(upTo: 0) == [])
    }

    @Test func primesFromSieve() async throws {
        let generator = PrimeGenerator()
        let primes = await generator.primes(upTo: 100_000)
        #expect(primes.count == 9_592)
        #expect(primes == (try primeNumbers(through: 100_000)))
    }

    // MARK: - primeFactorsConcurrent

    @Test func concurrentBatch() async throws {
        let results = try await primeFactorsConcurrent(of: [18, 100, 2, 5, 61])
        #expect(results == [18: [2, 3, 3], 100: [2, 2, 5, 5], 2: [2], 5: [5], 61: [61]])
    }

    @Test func concurrentBatchRejectsValuesBelowTwo() async {
        await #expect(throws: PrimeFactorizationError.invalidInput("All numbers must be greater than 1, got 1")) {
            try await primeFactorsConcurrent(of: [12, 1, 18])
        }
    }
}
