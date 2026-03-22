import Testing
@testable import PrimeFactorization

private struct testArgs {
  let testLabel: String
  let arg: Int
  let expectedResult: [Int]
}

@Suite("Prime Factorization Algorithms")
struct PrimeFactorizationTests2 {

  @Test("Basic set of test numbers")
  func smallComposite() {
    let testData: [testArgs] = [
      testArgs(testLabel: "Small composite number 18", arg: 18, expectedResult: [2, 3, 3]),
      testArgs(testLabel: "Small composite number 60", arg: 60, expectedResult: [2, 2, 3, 5]),
      testArgs(testLabel: "Small prime number 47", arg: 47, expectedResult: [47]),
      testArgs(testLabel: "Composite number 610", arg: 610, expectedResult: [2, 5, 61]),
      testArgs(testLabel: "Prime number 1373", arg: 1373, expectedResult: [1373]),
      testArgs(testLabel: "Large composite number 600000", arg: 600000, expectedResult: [2, 2, 2, 2, 2, 2, 3, 5, 5, 5, 5, 5]),
      testArgs(testLabel: "Large composite number 600001", arg: 600001, expectedResult: [19, 23, 1373]),
      testArgs(testLabel: "Larger composite number 600,000,004", arg: 600_000_004, expectedResult: [2, 2, 150000001]),
      testArgs(testLabel: "Larger prime number 1,200,000,041", arg: 1_200_000_041, expectedResult: [1200000041]),
    ]

    print("Running tests:")
    for data in testData {
      print("\(data.testLabel)")
      let result = data.arg.primeFactors
      #expect(result == data.expectedResult)
      print("\t\tResult: \(result)")
    }
  }

  @Test("Concurrent factorization")
  func concurrentTest() async throws {
    let numbers = [18, 100, 2, 5, 61]
    let results = try await primeFactorsConcurrent(of: numbers)
    #expect(results[18] == [2,3,3])
    #expect(results[100] == [2,2,5,5])
    #expect(results.count == 5)
  }

  @Test("Formatting extensions")
  func formattingExtensions() {
    let arr = [2,2,3,3,3,5]
    #expect(arr.simpleArrayDescription == "[2, 2, 3, 3, 3, 5]")
    #expect(arr.primeFactorizationString == "2^2 × 3^3 × 5")
    print(arr.simpleArrayDescription, "=", arr.primeFactorizationString)
  }
}
