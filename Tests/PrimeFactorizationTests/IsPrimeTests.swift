import Testing
@testable import PrimeFactorization

@Suite("isPrime")
struct IsPrimeTests {

    @Test func matchesSieveUpTo200K() {
        let primes = Set(sieveOfEratosthenes(limit: 200_000))
        for n in -5...200_000 {
            #expect(n.isPrime == primes.contains(n), "\(n)")
        }
    }

    @Test func allTypesAgree() {
        for n in 0...20_000 {
            let expected = n.isPrime
            #expect(Int64(n).isPrime == expected, "Int64 \(n)")
            #expect(UInt(n).isPrime == expected, "UInt \(n)")
            #expect(Int32(n).isPrime == expected, "Int32 (generic) \(n)")
        }
    }

    @Test func negativeValues() {
        #expect(!(-5).isPrime)
        #expect(!Int64(-5).isPrime)
        #expect(!Int32(-7).isPrime)
    }

    // MARK: - Miller-Rabin Range (>= 7,927²)

    @Test(arguments: [
        1_200_000_041, 3_037_000_453, 3_037_000_493, 2_305_843_009_213_693_951,
        1_000_000_000_000_000_003, 9_223_372_036_854_775_783,
    ])
    func largePrimes(n: Int) {
        #expect(n.isPrime)
    }

    @Test(arguments: [
        62_837_929,                      // 7927²
        3_037_000_493 * 3_037_000_453,   // semiprime
        4_611_686_014_132_420_609,       // (2³¹ - 1)²
        3_825_123_056_546_413_051,       // strong pseudoprime to bases 2...23
        Int.max,
    ])
    func largeComposites(n: Int) {
        #expect(!n.isPrime)
    }

    @Test func uintAboveIntMax() {
        #expect(!UInt.max.isPrime)
        #expect(UInt(18_446_744_073_709_551_557).isPrime)  // largest 64-bit prime
    }

    // MARK: - Generic Dispatch

    private func genericIsPrime<T: PrimeFactorizable>(_ value: T) -> Bool { value.isPrime }

    @Test func genericCallsUseConcreteOverride() {
        for n in [0, 1, 2, 97, 7919, 62_837_929, 1_000_000_000_000_000_003, Int.max] {
            #expect(genericIsPrime(n) == n.isPrime)
        }
    }
}
