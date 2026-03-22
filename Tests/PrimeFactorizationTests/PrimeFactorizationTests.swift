import Testing
import Foundation // for CFAbsoluteTimeGetCurrent()
@testable import PrimeFactorization

// Do these tests in a series, not parallel.
@Suite(.serialized) class PrimeFactorizationTests {

  @available(macOS 10.15, iOS 15.0, *)
  @Test func testPrimeFactors() async throws {
    var testValues: [Int] = Array(stride(from: 1, through: 20, by: 1))
    testValues.append(contentsOf: stride(from: (Int.max - 7), through: Int.max, by: 1))

    for testNumber in testValues {
      let testPrimes = testNumber.primeFactors
      let checkFactorsMultiply = testPrimes.reduce(1, { $0 * $1 })
      print("primeFactors of \(testNumber):", testPrimes)
      let allPrime = testPrimes.map { $0.isPrime }
      #expect(testNumber == checkFactorsMultiply &&
              !allPrime.contains(false))
    }
  }

  @available(macOS 10.15, iOS 15.0, *)
  @Test("prime factorization demonstration")
  func testPrimeFactorization() async throws {
    await demonstratePrimeFactorization()
  }

  @available(macOS 12.0, iOS 15.0, *)
  @Test("benchmark Prime Generation demonstration")
  func benchmarkPrimeFactorization() async throws {
    await benchmarkPrimeGeneration()
  }

  // same as above except that it uses the new primeNumbers()
  @available(macOS 10.15, iOS 15.0, *)
  @Test func testPrimeNumbers() async throws {

    // Test error cases
    #expect(throws: PrimeFactorizationError.self) {
      try primeNumbers(through: -1)
    }
    #expect(throws: PrimeFactorizationError.self) {
      try primeNumbers(through: 0)
    }
    #expect(throws: PrimeFactorizationError.self) {
      try primeNumbers(from: 5, through: 2)
    }
    
    let testNumber = 31
    for checkNumber in stride(from: 2, through: testNumber, by: 1) {
      let allPrimes = try primeNumbers(through: checkNumber)
      print("primeNumbers(through:\(checkNumber)):", allPrimes)
    }
    #expect(try primeNumbers(from: 2, through: 2) == [2])
    #expect(try primeNumbers(from: 2, through: 3) == [2, 3])
    #expect(try primeNumbers(from: 3, through: 3) == [3])
    #expect(try primeNumbers(through: 3) == [2, 3])
    #expect(try primeNumbers(through: 4) == [2, 3])
    #expect(try primeNumbers(through: 5) == [2, 3, 5])
    #expect(try primeNumbers(from: 3, through: 5) == [3, 5])
    #expect(try primeNumbers(through: 7) == [2, 3, 5, 7])
    #expect(try primeNumbers(through: 9) == [2, 3, 5, 7])
    #expect(try primeNumbers(from: 8, through: 9) == [])
    #expect(try primeNumbers(through: 11) == [2, 3, 5, 7, 11])
    #expect(try primeNumbers(through: 13) == [2, 3, 5, 7, 11, 13])
    #expect(try primeNumbers(through: 15) == [2, 3, 5, 7, 11, 13])
    #expect(try primeNumbers(through: 23) == [2, 3, 5, 7, 11, 13, 17, 19, 23])
    #expect(try primeNumbers(from: 8, through: 23) == [11, 13, 17, 19, 23])

    /// https://www.mathematical.com/primes0to1000k.html
    #expect(try primeNumbers(through: 2_000_000).count == 148933)
    #expect(try primeNumbers(through: 5_000_000).count == 348513)
    #expect(try primeNumbers(from: 100_000, through: 10_300_000).suffix(5) == [10299917, 10299953, 10299973, 10299983, 10299997])

    print("\nlast 5 primes from 9_999_000 to 10_000_000:")
    let last5PrimesFrom9_999_000_to_10_000_000 = try primeNumbers(from: 9_999_000, through: 10_000_000).suffix(5)
    #expect(last5PrimesFrom9_999_000_to_10_000_000 == [9999937, 9999943, 9999971, 9999973, 9999991])
    print(last5PrimesFrom9_999_000_to_10_000_000.map({ val in
      val.formatted()
    }))
  }

  @available(macOS 10.15, iOS 15.0, *)
  @Test func isPrime() async throws {
    let maxNumber: Int = 200
    for number in (1...maxNumber).lazy.map({ $0 }) {
      print(number.isPrime ? "\(number) is prime" : "\(number) is composite")
    }
  }

  @Test func largestPrime() async throws {
    var record: [Int?] = []
    for testNumber in stride(from: -4, through: 30, by: 1) {
      let largestPrime = testNumber.largestPrimeFactor
      record.append(largestPrime)
      print("largestPrimeFactor of  \t\(testNumber) is: \t \(largestPrime.map(String.init) ?? "nil")  \t\(testNumber.primeFactors)")
    }
    #expect(record.map { $0 ?? 1 } == [1, 1, 1, 1, 1, 1, 2, 3, 2, 5, 3, 7, 2, 3, 5, 11, 3, 13, 7, 5, 2, 17, 3, 19, 5, 7, 11, 23, 3, 5, 13, 3, 7, 29, 5])
  }

  @Test func smallestPrime() async throws {
    var record: [Int?] = []
    for testNumber in stride(from: -4, through: 30, by: 1) {
      let smallestPrime = testNumber.smallestPrimeFactor
      record.append(smallestPrime)
      print("smallestPrimeFactor of  \t\(testNumber) is: \t \(smallestPrime.map(String.init) ?? "nil")  \t\(testNumber.primeFactors)")
    }
    #expect(record.map { $0 ?? 1 } == [1, 1, 1, 1, 1, 1, 2, 3, 2, 5, 2, 7, 2, 3, 2, 11, 2, 13, 2, 3, 2, 17, 2, 19, 2, 3, 2, 23, 2, 5, 2, 3, 2, 29, 2])
  }

  @Test func testAllFactors() async throws {
    let testSet = ([
      (-1, [Int]()),
      (0, []),
      (1, [1]),
      (2, [1, 2]),
      (3, [1, 3]),
      (5, [1, 5]),
      (33, [1, 3, 11, 33]),
      (60, [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60]),
      (48837371, [1, 11, 47, 517, 94463, 1039093, 4439761, 48837371]),
                   ]).map { $0 }
    for (test, truth) in testSet {
      let factors = test.allFactors
      print("allFactors of \(test):", factors)
      #expect(factors == truth)
    }
  }

  
    /// Test the 10 largest Ints
  @Test func primeFactorsTest() async throws {
    let testRange =  (Int.max - 9)...Int.max // test with 10 largest Ints
    let keys = testRange.map { $0 }
    let values = keys.map { $0.primeFactors }
    for (k, v) in zip(keys, values).sorted(by: { $0.0 < $1.0 }) {
      print("\(k): \(v)")
    }
  }

  @available(macOS 10.15, iOS 15.0, *)
  @Test func primeNumbersTest() async throws {
    let testRange =  (Int.max - 300)...(Int.max)
    let primes = try primeNumbers(from: testRange.lowerBound, through: testRange.upperBound)
    print(primes.count.formatted(), "Primes found in test range: \(testRange.lowerBound) ... \(testRange.upperBound)" )
    if primes.count > 11 {
      let prefixP = primes.prefix(upTo: 4)
      let suffixP = primes.suffix(9)
      print(prefixP.description + "..." + suffixP.description)
    } else {
      print(primes.description)
    }
  }

  @available(macOS 10.15, iOS 15.0, *)
  @Test("primesByJump6Method Test")
  func primesByJump6MethodTest() async throws {
    let testRange = 1...500_000
    let primes = try primeNumbers(from: testRange.lowerBound, through: testRange.upperBound)
    print(primes.count.formatted(), "Primes found in testRange" )
    if primes.count > 11 {
      let prefixP = primes.prefix(upTo: 4)
      let suffixP = primes.suffix(9)
      print(prefixP.description + "..." + suffixP.description)
    } else {
      print(primes.description)
    }
  }

  struct testArgs {
    let testLabel: String
    let start: Int
    let end: Int
    let expectedPrimes: [Int]
  }

  @Test func primeRangeTest() async throws {
    let tArgs: [testArgs] = [
      testArgs(testLabel: "Small Range", start: 2, end: 37,
               expectedPrimes: [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]),
      testArgs(testLabel: "Larger Range", start: 1000, end: 1100,
               expectedPrimes: [1009, 1013, 1019, 1021, 1031, 1033, 1039, 1049, 1051, 1061, 1063, 1069, 1087, 1091, 1093, 1097]),
      testArgs(testLabel: "Large Numbers", start: 1_000_000_000_000, end: 1_000_000_000_100,
               expectedPrimes: [1000000000039, 1000000000061, 1000000000063, 1000000000091]),
    ]
    for args in tArgs {
      let lowerBound: Int = args.start
      let upperBound: Int = args.end
      let expectedPrimes: [Int] = args.expectedPrimes
      print("Testing from \(lowerBound) to \(upperBound)")

      let result = try primeNumbers(from: lowerBound, through: upperBound)
      print("primes from \(lowerBound) to \(upperBound):", result, "\n")
      #expect(result == expectedPrimes)
    }
  }
}
