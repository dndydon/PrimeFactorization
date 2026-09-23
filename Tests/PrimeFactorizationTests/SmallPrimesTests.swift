import Testing
@testable import PrimeFactorization

@Suite("smallPrimes table")
struct SmallPrimesTests {

    @Test func shape() {
        #expect(smallPrimes.count == 1000)
        #expect(smallPrimes.first == 2)
        #expect(smallPrimes.last == 7919)
    }

    @Test func matchesSieve() {
        #expect(smallPrimes == sieveOfEratosthenes(limit: 7919))
    }

    @Test func everyEntryIsPrimeByGenericTrialDivision() {
        for p in smallPrimes {
            #expect(Int32(p).isPrime, "\(p)")
        }
    }
}
