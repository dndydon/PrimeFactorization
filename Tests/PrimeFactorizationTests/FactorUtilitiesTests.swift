import Testing
@testable import PrimeFactorization

@Suite("allFactors, largest/smallest prime factor, formatting")
struct FactorUtilitiesTests {

    // MARK: - allFactors

    @Test(arguments: [
        (-1, []), (0, []), (1, [1]), (2, [1, 2]), (3, [1, 3]), (5, [1, 5]),
        (33, [1, 3, 11, 33]),
        (60, [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60]),
        (48_837_371, [1, 11, 47, 517, 94463, 1_039_093, 4_439_761, 48_837_371]),
    ] as [(Int, [Int])])
    func allFactors(n: Int, expected: [Int]) {
        #expect(n.allFactors == expected)
    }

    @Test func allFactorsMatchesGenericDivisorScan() {
        for n in 1...5_000 {
            #expect(n.allFactors == Int32(n).allFactors.map { Int($0) }, "\(n)")
        }
    }

    @Test func allFactorsLargeValues() {
        #expect(720_720.allFactors.count == 240)
        let maxDivisors = Int.max.allFactors
        #expect(maxDivisors.count == 96)
        #expect(maxDivisors.first == 1)
        #expect(maxDivisors.suffix(3) == [188_232_082_384_791_343, 1_317_624_576_693_539_401, Int.max])
    }

    @Test func allFactorsOtherTypes() {
        #expect(Int64(60).allFactors == [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60])
        #expect(UInt(60).allFactors == [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60])
        #expect(Int64(-4).allFactors == [])
    }

    // MARK: - largestPrimeFactor / smallestPrimeFactor

    @Test func largestPrimeFactor() {
        let results = (-4...30).map { $0.largestPrimeFactor }
        #expect(results == [nil, nil, nil, nil, nil, nil, 2, 3, 2, 5, 3, 7, 2, 3, 5, 11, 3, 13, 7, 5, 2, 17, 3, 19, 5, 7, 11, 23, 3, 5, 13, 3, 7, 29, 5])
    }

    @Test func smallestPrimeFactor() {
        let results = (-4...30).map { $0.smallestPrimeFactor }
        #expect(results == [nil, nil, nil, nil, nil, nil, 2, 3, 2, 5, 2, 7, 2, 3, 2, 11, 2, 13, 2, 3, 2, 17, 2, 19, 2, 3, 2, 23, 2, 5, 2, 3, 2, 29, 2])
    }

    // MARK: - Formatting

    @Test func simpleArrayDescription() {
        #expect([2, 2, 3, 3, 3, 5].simpleArrayDescription == "[2, 2, 3, 3, 3, 5]")
        #expect([Int]().simpleArrayDescription == "[]")
    }

    @Test func primeFactorizationString() {
        #expect([2, 2, 3, 3, 3, 5].primeFactorizationString == "2^2 × 3^3 × 5")
        #expect(5040.primeFactors.primeFactorizationString == "2^4 × 3^2 × 5 × 7")
        #expect([7].primeFactorizationString == "7")
    }
}
