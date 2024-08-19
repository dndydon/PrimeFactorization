import Testing
import Foundation
@testable import PrimeFactorization

@Test func primeFactorsTest() async throws {
  let testNumber = 10
  let testPrimes = testNumber.primeFactors
  let check = testPrimes.reduce(1, { $0 * $1 })
  //print(check, testPrimes)
  print("primeFactors of: \(testNumber)",
        24.primeFactors)
  #expect(testNumber == check)
}

@Test func primeNumbersBelowTest() async throws {
  let testNumber = 100
  // this is too slow for large numbers
  let allPrimes = primeNumbersBelow(testNumber)
  print("primeNumbersBelow: \(testNumber)",
        allPrimes)
}
