import Testing
import Foundation // for CFAbsoluteTimeGetCurrent()
@testable import PrimeFactorization

// Do these tests in a series, not parallel.
@Suite(.serialized) class PrimeFactorizationTests {

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

  @Test("Speed comparison: classic vs optimized prime factorization")
  func comparePrimeFactorizationSpeeds() async throws {
    let testNumbers = Array(3_000...18_500)

    // Time classic primeFactors
    let startClassic = CFAbsoluteTimeGetCurrent()
    for number in testNumbers {
      _ = number.primeFactors
    }
    let endClassic = CFAbsoluteTimeGetCurrent()
    let elapsedClassic = endClassic - startClassic
    let classicRate = Double(testNumbers.count) / elapsedClassic // iterations per second

    // Time optimized version
    let startOptimized = CFAbsoluteTimeGetCurrent()
    for number in testNumbers {
      _ = try await primeFactorsOptimized(of: number)
    }
    let endOptimized = CFAbsoluteTimeGetCurrent()
    let elapsedOptimized = endOptimized - startOptimized
    let optimizedRate = Double(testNumbers.count) / elapsedOptimized // iterations per second

    // Calculate and print comparison statistics
    let (winner, faster, slower) = elapsedClassic < elapsedOptimized ? ("primeFactors classic", elapsedClassic, elapsedOptimized) : ("primeFactorsOptimized(of:)", elapsedOptimized, elapsedClassic)
    let percentFaster = ((slower - faster) / slower)
    print("\(winner) is \(percentFaster.formatted(.percent)) faster (classic: \(elapsedClassic.formatted()), optimized: \(elapsedOptimized.formatted()))")
    print(Int(classicRate).formatted(.number), "iterations per second (classic)")
    print(Int(optimizedRate).formatted(.number), "iterations per second (optimized)")
    #expect(optimizedRate < classicRate, "Optimized version should be faster")
  }

  @Test("prime factorization demonstration 2")
  func testPrimeFactorization() async throws {
    Task {
      await demonstratePrimeFactorization()
    }
  }

  // same as above except that it uses the new primeNumbers()
  @Test func testPrimeNumbers() async throws {

    #expect(primeNumbers(through: -1) == []) // need to throw an error
    #expect(primeNumbers(through: 0) == [])
    #expect(primeNumbers(through: 1) == [])
    let testNumber = 31
    for checkNumber in stride(from: 2, through: testNumber, by: 1) {
      let allPrimes = primeNumbers(through: checkNumber)
      print("primeNumbers(through:\(checkNumber)):", allPrimes)
    }
    #expect(primeNumbers(from: 2, through: 2) == [2])
    #expect(primeNumbers(from: 2, through: 3) == [2, 3])
    #expect(primeNumbers(from: 3, through: 3) == [3])
    #expect(primeNumbers(through: 3) == [2, 3])
    #expect(primeNumbers(through: 4) == [2, 3])
    #expect(primeNumbers(through: 5) == [2, 3, 5])
    #expect(primeNumbers(from: 3, through: 5) == [3, 5])
    #expect(primeNumbers(through: 7) == [2, 3, 5, 7])
    #expect(primeNumbers(through: 9) == [2, 3, 5, 7])
    #expect(primeNumbers(from: 8, through: 9) == [])
    #expect(primeNumbers(through: 11) == [2, 3, 5, 7, 11])
    #expect(primeNumbers(through: 13) == [2, 3, 5, 7, 11, 13])
    #expect(primeNumbers(through: 15) == [2, 3, 5, 7, 11, 13])
    #expect(primeNumbers(through: 23) == [2, 3, 5, 7, 11, 13, 17, 19, 23])
    #expect(primeNumbers(from: 8, through: 23) == [11, 13, 17, 19, 23])

    /// https://www.mathematical.com/primes0to1000k.html
    #expect(primeNumbersUpTo(2_000_000).count == 148933)
    #expect(primeNumbers(through: 2_000_000).count == 148933)
    #expect(primeNumbers(through: 5_000_000).count == 348513)
    #expect(primeNumbers(from: 100_000, through: 10_300_000).suffix(5) == [10299917, 10299953, 10299973, 10299983, 10299997])

    print("\nlast 5 primes from 9_999_000 to 10_000_000:")
    let last5PrimesFrom9_999_000_to_10_000_000 = primeNumbers(from: 9_999_000, through: 10_000_000).suffix(5)
    #expect(last5PrimesFrom9_999_000_to_10_000_000 == [9999937, 9999943, 9999971, 9999973, 9999991])
    print(last5PrimesFrom9_999_000_to_10_000_000.map({ val in
      val.formatted()
    }))
  }


  //@available(iOS 15.0, *)
  @Test func speedTestPrimeNumbers() async throws {
    // speed test between two different prime factor algorithms:
    // primeNumbersUpTo() and primeNumbers(:)
    let testNumbers = 3000...3500
    let list = testNumbers.lazy.map { $0 }
    let startTime1 = CFAbsoluteTimeGetCurrent()
    for number in list {
      let _ = primeNumbersUpTo(number)      // old way
    }
    let endTime1 = CFAbsoluteTimeGetCurrent()
    for number in list {
      let _ = primeNumbers(through: number) // new way
    }
    let endTime2 = CFAbsoluteTimeGetCurrent()
    let totalElapsed1 = endTime1 - startTime1
    let totalElapsed2 = endTime2 - endTime1

    print("totalElapsed1: primeNumbersUpTo ", totalElapsed1.formatted())
    print("totalElapsed2: primeNumbers ", totalElapsed2.formatted())
    let difference = ((totalElapsed1 - totalElapsed2)/totalElapsed1).formatted(.percent)
    print("primeNumbers(through:) is \(difference) faster than primeNumbersUpTo()")
  }

  //@available(iOS 16.0, *)
  @Test func isPrime() async throws {
    let maxNumber: Int = 200
    for number in (1...maxNumber).lazy.map({ $0 }) {
      print(number.isPrime ? "\(number) is prime" : "\(number) is composite")
    }
  }

  @Test func largestPrime() async throws {
    var record: [Int] = []
    for testNumber in stride(from: -4, through: 30, by: 1) {
      let largestPrime = testNumber.largestPrimeFactor ?? 1
      record.append(largestPrime)
      print("largestPrimeFactor of  \t\(testNumber) is: \t \(largestPrime)  \t\(testNumber.primeFactors)")
    }
    //print(record)
    #expect(record == [1, 1, 1, 1, 1, 1, 2, 3, 2, 5, 3, 7, 2, 3, 5, 11, 3, 13, 7, 5, 2, 17, 3, 19, 5, 7, 11, 23, 3, 5, 13, 3, 7, 29, 5])
  }

  @Test func smallestPrime() async throws {
    var record: [Int] = []
    for testNumber in stride(from: -4, through: 30, by: 1) {
      let smallestPrime = testNumber.smallestPrimeFactor ?? 1
      record.append(smallestPrime)
      print("smallestPrimeFactor of  \t\(testNumber) is: \t \(smallestPrime)  \t\(testNumber.primeFactors)")
    }
    //print(record)
    #expect(record == [1, 1, 1, 1, 1, 1, 2, 3, 2, 5, 2, 7, 2, 3, 2, 11, 2, 13, 2, 3, 2, 17, 2, 19, 2, 3, 2, 23, 2, 5, 2, 3, 2, 29, 2])
  }

  @Test func testAllFactors() async throws {
    let testSet = ([  //-1, 0, 1, 2, 3, 5, 33, 60, 48837371
      (-1, []),
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
      let factors = allFactors(of: test)
      print("allFactors of \(test):", factors)
      #expect(factors == truth)
    }
  }


  @Test func primeFactorsTest() async throws {
    let testRange =  (Int.max - 10)...Int.max // test with 10 largest Ints
    let keys = testRange.map { $0 }
    let values = keys.map { $0.primeFactors }
    for (k, v) in zip(keys, values).sorted(by: { $0.0 < $1.0 }) {
      print("\(k): \(v)")
    }
  }

  @Test func startCursorTest() async throws {
    let testRange =  1...400
    let testSet = testRange.map { $0 }
    var results: [Int: [Int]] = [:]
    for test in testSet {
      let cursor = startCursor(from: test)
      //print(test, cursors.description)
      results[test] = [cursor, cursor+2]
    }
    let krell = results.sorted(by: { $0.key < $1.key })
    for (k, v) in krell {
      print(k, v, v.map(\.isPrime))
    }
  }

  @Test func primeNumbersTest() async throws {
    let testRange =  (Int.max - 300)...(Int.max)  // [9223372036854775549, 9223372036854775643, 9223372036854775783]
    //let testRange = 80...950   // 80...950: [83, 89, 97, 101]...[883, 887, 907, 911, 919, 929, 937, 941, 947]
    let primes = PrimeIteratorSequence(from: testRange.lowerBound, through: testRange.upperBound).map { $0 }
    //let primes = primeNumbers(from: testRange.lowerBound, through: testRange.upperBound).map { $0 }
    print(primes.count.formatted(), "Primes found in test range: \(testRange.lowerBound) ... \(testRange.upperBound)" )
    if primes.count > 11 {  // too many to print all
      let prefixP = primes.prefix(upTo: 4)
      let suffixP = primes.suffix(9)
      print(prefixP.description + "..." + suffixP.description)
    } else {
      print(primes.description)
    }
  }

  @Test("primesByJump6Method Test")
  func primesByJump6MethodTest() async throws {
    let testRange = 1...500_000   // 41,538 Primes in 0.065 sec [2, 3, 5, 7]...[499883, 499897, 499903, 499927, 499943, 499957, 499969, 499973, 499979]
    //let primes = PrimeIteratorSequence(from: testRange.lowerBound, through: testRange.upperBound).map { $0 }
    let primes = primeNumbers(from: testRange.lowerBound, through: testRange.upperBound)
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

  @Test func primeIteratorTest() async throws {
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
      var result: [Int] = []

      result = []
      let primes = PrimeIteratorSequence(from: lowerBound, through: upperBound)
      // use the iterator here...
      for nextPrime in primes {
        result.append(nextPrime)
      }
      print("primes from \(lowerBound) to \(upperBound):", result, "\n")
      #expect(result == expectedPrimes)
    }
  }
}

