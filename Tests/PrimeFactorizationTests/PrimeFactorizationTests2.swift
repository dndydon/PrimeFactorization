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
  func smallComposite() async throws {
    let testData: [testArgs] = [
      testArgs(testLabel: "Small composite number 18", arg: 18, expectedResult: [2, 3, 3]),
      testArgs(testLabel: "Small composite number 60", arg: 60, expectedResult: [2, 2, 3, 5]),
      testArgs(testLabel: "Small prime number 47", arg: 47, expectedResult: [47]),
      testArgs(testLabel: "Composite number 610", arg: 610, expectedResult: [2, 5, 61]),
      testArgs(testLabel: "Prime number 1373", arg: 1373, expectedResult: [1373]),
      testArgs(testLabel: "Large composite number 600000", arg: 600000, expectedResult: [2, 2, 2, 2, 2, 2, 3, 5, 5, 5, 5, 5]),
      testArgs(testLabel: "Large composite number 600001", arg: 600001, expectedResult: [19, 23, 1373]),
    ]

    for data in testData {
      print("Running test: \(data.testLabel)")
      let result = try await primeFactors(of: data.arg)
      #expect(result == data.expectedResult)
      print("\t\tResult: \(result)")
    }
  }

  @Test("Optimized: Medium composite number")
  func optimizedMediumComposite() async throws {
    let result = try await primeFactorsOptimized(of: 5040)
    #expect(result == [2,2,2,2,3,3,5,7])
  }

  @Test("Concurrent factorization")
  func concurrentTest() async throws {
    let numbers = [18, 100, 2, 5, 61]
    let results = try await primeFactorsConcurrent(of: numbers)
    #expect(results[18] == [2,3,3])
    #expect(results[100] == [2,2,5,5])
    #expect(results.count == 5)

  }

  @Test("Error: invalid number")
  func errorCase() async {
    do {
      _ = try await primeFactors(of: -1)
      #expect(Bool(false), "Should throw on -1")
    } catch {
      #expect(String(describing: error).contains("invalidNumber"))
    }
  }

  @Test("Formatting extensions")
  func formattingExtensions() async throws {
    let arr = [2,2,3,3,3,5]
    #expect(arr.simpleArrayDescription == "[2, 2, 3, 3, 3, 5]")
    #expect(arr.primeFactorizationString == "2^2 × 3^3 × 5")
    print(arr.simpleArrayDescription, "=", arr.primeFactorizationString)
  }
}
