import Testing
@testable import PrimeFactorization

// Int32 has no engine override, so this conformance exercises the generic protocol-extension
// defaults and gives the tests an independent trial-division oracle for values up to Int32.max.
extension Int32: PrimeFactorizable {}

@Suite("primeFactors")
struct PrimeFactorsTests {

    // MARK: - Known Answers

    @Test(arguments: [
        (0, []), (1, []), (-1, []), (-60, []),
        (2, [2]), (3, [3]), (15, [3, 5]), (18, [2, 3, 3]), (47, [47]), (60, [2, 2, 3, 5]),
        (64, [2, 2, 2, 2, 2, 2]), (97, [97]), (105, [3, 5, 7]), (610, [2, 5, 61]),
        (1373, [1373]), (5040, [2, 2, 2, 2, 3, 3, 5, 7]),
        (600_000, [2, 2, 2, 2, 2, 2, 3, 5, 5, 5, 5, 5]), (600_001, [19, 23, 1373]),
        (600_000_004, [2, 2, 150_000_001]), (1_200_000_041, [1_200_000_041]),
        (987_654_321, [3, 3, 17, 17, 379_721]),
    ] as [(Int, [Int])])
    func knownAnswers(n: Int, expected: [Int]) {
        #expect(n.primeFactors == expected)
    }

    @Test func powersOfTwo() {
        for exponent in 1...62 {
            #expect((1 << exponent).primeFactors == Array(repeating: 2, count: exponent))
        }
    }

    /// Ground truth computed by v3.1's pure trial division.
    @Test(arguments: [
        (Int.max - 9, [2, 34421, 133_978_850_655_919]),
        (Int.max - 8, [17, 17, 17, 2927, 641_387_128_649]),
        (Int.max - 7, [2, 2, 2, 3, 3, 5, 5, 7, 11, 13, 31, 41, 61, 151, 331, 1321]),
        (Int.max - 6, [157, 1973, 29_775_769_179_641]),
        (Int.max - 5, [2, 37, 9_902_437, 12_586_817_029]),
        (Int.max - 4, [3, 71, 42013, 1_030_686_124_187]),
        (Int.max - 3, [2, 2, 2_305_843_009_213_693_951]),
        (Int.max - 2, [5, 23, 53_301_701, 1_504_703_107]),
        (Int.max - 1, [2, 3, 715_827_883, 2_147_483_647]),
        (Int.max, [7, 7, 73, 127, 337, 92737, 649_657]),
    ] as [(Int, [Int])])
    func nearIntMax(n: Int, expected: [Int]) {
        #expect(n.primeFactors == expected)
    }

    // MARK: - Large-Factor Paths (Pollard-Brent rho)

    @Test func tableBoundary() {
        // 7919 is the last table prime; 7927 is the next prime.
        #expect((7927 * 7927).primeFactors == [7927, 7927])
        #expect((7919 * 7927).primeFactors == [7919, 7927])
    }

    @Test func semiprimeOfTwo31BitPrimes() {
        #expect((3_037_000_493 * 3_037_000_453).primeFactors == [3_037_000_453, 3_037_000_493])
    }

    /// Smallest inputs found that reach Pollard-Brent's recovery branches:
    /// 7927 × 7937 overshoots a batch and retraces; 7927 × 8219 needs a second constant `c`.
    @Test func pollardBrentRecoveryPaths() {
        #expect(62_916_599.primeFactors == [7927, 7937])
        #expect(65_152_013.primeFactors == [7927, 8219])
    }

    @Test func squareOfMersennePrime() {
        #expect(4_611_686_014_132_420_609.primeFactors == [2_147_483_647, 2_147_483_647])
    }

    // MARK: - Int64 and UInt

    /// Ground truth computed by v3.1's pure trial division.
    @Test func uintNearMax() {
        #expect((UInt.max - 3).primeFactors == [2, 2, 3, 715_827_883, 2_147_483_647])
        #expect((UInt.max - 2).primeFactors == [13, 3889, 364_870_227_143_809])
        #expect((UInt.max - 1).primeFactors == [2, 7, 7, 73, 127, 337, 92737, 649_657])
        #expect(UInt.max.primeFactors == [3, 5, 17, 257, 641, 65537, 6_700_417])
    }

    @Test func int64AndUIntMatchInt() {
        for n in [0, 1, 2, 60, 1373, 600_000_000_004, Int.max - 1, Int.max] {
            let expected = n.primeFactors
            #expect(Int64(n).primeFactors.map { Int($0) } == expected)
            #expect(UInt(n).primeFactors.map { Int($0) } == expected)
        }
        #expect(Int64(-60).primeFactors == [])
    }

    // MARK: - Engine vs Generic Oracle

    @Test func engineMatchesGenericTrialDivision() {
        for n in 2...20_000 {
            #expect(n.primeFactors == Int32(n).primeFactors.map { Int($0) }, "\(n)")
        }
        for n in [62_837_929, 2_147_483_647, 2_147_483_646, 2_147_395_600] {
            #expect(n.primeFactors == Int32(n).primeFactors.map { Int($0) }, "\(n)")
        }
    }

    // MARK: - Generic Dispatch

    private func genericPrimeFactors<T: PrimeFactorizable>(_ value: T) -> [T] { value.primeFactors }

    @Test func genericCallsUseConcreteOverride() {
        for n in [0, 1, 2, 60, 7919, 62_710_561, 600_000_000_004, Int.max] {
            #expect(genericPrimeFactors(n) == n.primeFactors)
            #expect(genericPrimeFactors(UInt(n)) == UInt(n).primeFactors)
        }
    }
}
