import Testing
@testable import PrimeFactorization

@Suite("primeNumbers(from:through:)")
struct PrimeNumbersTests {

    // MARK: - Errors

    @Test func startMustBePositive() {
        #expect(throws: PrimeFactorizationError.invalidInput("startIndex must be > 0, got 0")) {
            try primeNumbers(from: 0, through: 10)
        }
    }

    @Test func startMustNotExceedEnd() {
        #expect(throws: PrimeFactorizationError.self) { try primeNumbers(through: -1) }
        #expect(throws: PrimeFactorizationError.self) { try primeNumbers(through: 0) }
        #expect(throws: PrimeFactorizationError.self) { try primeNumbers(from: 5, through: 2) }
    }

    @Test func rangeTooLarge() {
        // A span no configured limit would allow, so this holds even if a benchmark raised the limit.
        #expect(throws: PrimeFactorizationError.rangeTooLarge(Int.max - 1)) {
            try primeNumbers(from: 1, through: Int.max)
        }
    }

    // MARK: - Small Ranges

    @Test(arguments: [
        (2, 2, [2]), (2, 3, [2, 3]), (3, 3, [3]), (2, 4, [2, 3]), (2, 5, [2, 3, 5]),
        (3, 5, [3, 5]), (2, 9, [2, 3, 5, 7]), (8, 9, []), (2, 15, [2, 3, 5, 7, 11, 13]),
        (8, 23, [11, 13, 17, 19, 23]),
        (2, 37, [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]),
        (1000, 1100, [1009, 1013, 1019, 1021, 1031, 1033, 1039, 1049, 1051, 1061, 1063, 1069, 1087, 1091, 1093, 1097]),
    ] as [(Int, Int, [Int])])
    func smallRanges(start: Int, end: Int, expected: [Int]) throws {
        #expect(try primeNumbers(from: start, through: end) == expected)
    }

    /// Regression: v3.2.0 and earlier skipped a 6k+1 start value on the trial-division path.
    @Test(arguments: [(7, 7, [7]), (13, 13, [13]), (31, 33, [31]), (37, 40, [37])] as [(Int, Int, [Int])])
    func startOnSixKPlusOne(start: Int, end: Int, expected: [Int]) throws {
        #expect(try primeNumbers(from: start, through: end) == expected)
    }

    // MARK: - Large Ranges (sieve path)

    @Test func countsUpTo15Million() throws {
        let primes = try primeNumbers(through: 15_000_000)
        #expect(primes.count == 970_704)
        #expect(primes.prefix { $0 <= 5_000_000 }.count == 348_513)
        #expect(primes.prefix { $0 <= 2_000_000 }.count == 148_933)
        #expect(try primeNumbers(through: 500_000).count == 41_538)
    }

    @Test func tailsOfLargeRanges() throws {
        #expect(try primeNumbers(from: 100_000, through: 10_300_000).suffix(5) == [10_299_917, 10_299_953, 10_299_973, 10_299_983, 10_299_997])
        #expect(try primeNumbers(from: 9_999_000, through: 10_000_000).suffix(5) == [9_999_937, 9_999_943, 9_999_971, 9_999_973, 9_999_991])
    }

    // MARK: - Huge Values (trial-division path)

    @Test func nearTrillion() throws {
        #expect(try primeNumbers(from: 1_000_000_000_000, through: 1_000_000_000_100) == [1_000_000_000_039, 1_000_000_000_061, 1_000_000_000_063, 1_000_000_000_091])
    }

    /// Ground truth computed by v3.1's pure trial division.
    @Test func nearQuintillion() throws {
        #expect(try primeNumbers(from: 1_000_000_000_000_000_000, through: 1_000_000_000_000_000_200) == [
            1_000_000_000_000_000_003, 1_000_000_000_000_000_009, 1_000_000_000_000_000_031,
            1_000_000_000_000_000_079, 1_000_000_000_000_000_177, 1_000_000_000_000_000_183,
        ])
    }

    @Test func nearIntMax() throws {
        // Int.max - 300 is 6k+1 and prime; v3.2.0 and earlier missed it.
        #expect(try primeNumbers(from: Int.max - 300, through: Int.max) == [
            9_223_372_036_854_775_507, 9_223_372_036_854_775_549,
            9_223_372_036_854_775_643, 9_223_372_036_854_775_783,
        ])
    }

    // MARK: - Sieve vs Trial Division

    @Test(arguments: [1...2, 1...10_000, 7_900...8_000, 1_000_000...1_001_000, 9_990_000...10_000_000])
    func matchesIsPrimeFilter(range: ClosedRange<Int>) throws {
        #expect(try primeNumbers(from: range.lowerBound, through: range.upperBound) == range.filter(\.isPrime))
    }
}
