import Testing
import Foundation // for CFAbsoluteTimeGetCurrent()
@testable import PrimeFactorization

// Do these tests in a series, not parallel.
@Suite(.serialized) class PrimeFactorizationTests {

  @Test func testPrimeFactors() async throws {
    for testNumber in stride(from: 2, through: 567, by: 1) {
      let testPrimes = testNumber.primeFactors
      let checkFactorsMultiply = testPrimes.reduce(1, { $0 * $1 })
      print("primeFactors of \(testNumber):", testNumber.primeFactors)
      let allPrime = testNumber.primeFactors.map { $0.isPrime }
      #expect(testNumber == checkFactorsMultiply &&
              !allPrime.contains(false))
    }
  }

  @Test func testPrimeNumbersUpTo() async throws {
    #expect(primeNumbersUpTo(1_000_001) == [])
    #expect(primeNumbersUpTo(-1) == [])
    #expect(primeNumbersUpTo(0) == [])
    #expect(primeNumbersUpTo(1) == [])
    let testNumber = 31
    for checkNumber in stride(from: 2, through: testNumber, by: 1) {
      let allPrimes = primeNumbersUpTo(checkNumber)
      print("primeNumbersUpTo \(checkNumber):", allPrimes)
    }
    #expect(primeNumbersUpTo(2) == [2])
    #expect(primeNumbersUpTo(3) == [2, 3])
    #expect(primeNumbersUpTo(4) == [2, 3])
    #expect(primeNumbersUpTo(5) == [2, 3, 5])
    #expect(primeNumbersUpTo(7) == [2, 3, 5, 7])
    #expect(primeNumbersUpTo(9) == [2, 3, 5, 7])
    #expect(primeNumbersUpTo(11) == [2, 3, 5, 7, 11])
    #expect(primeNumbersUpTo(13) == [2, 3, 5, 7, 11, 13])
    #expect(primeNumbersUpTo(15) == [2, 3, 5, 7, 11, 13])
    #expect(primeNumbersUpTo(23) == [2, 3, 5, 7, 11, 13, 17, 19, 23])

    /// https://www.mathematical.com/primes0to1000k.html
    //#expect(primeNumbersUpTo(1_000_000).count == 78498)
  }

  // same as above except that it uses the new primeNumbers()
  @Test func testPrimeNumbers() async throws {
    #expect(primeNumbers(through: 1_000_001) == [])
    #expect(primeNumbers(through: -1) == [])
    #expect(primeNumbers(through: 0) == [])
    #expect(primeNumbers(through: 1) == [])
    let testNumber = 31
    for checkNumber in stride(from: 2, through: testNumber, by: 1) {
      let allPrimes = primeNumbers(through: checkNumber)
      print("primeNumbers(through:\(checkNumber)):", allPrimes)
    }
    #expect(primeNumbers(through: 2) == [2])
    #expect(primeNumbers(through: 3) == [2, 3])
    #expect(primeNumbers(through: 4) == [2, 3])
    #expect(primeNumbers(through: 5) == [2, 3, 5])
    #expect(primeNumbers(through: 7) == [2, 3, 5, 7])
    #expect(primeNumbers(through: 9) == [2, 3, 5, 7])
    #expect(primeNumbers(through: 11) == [2, 3, 5, 7, 11])
    #expect(primeNumbers(through: 13) == [2, 3, 5, 7, 11, 13])
    #expect(primeNumbers(through: 15) == [2, 3, 5, 7, 11, 13])
    #expect(primeNumbers(through: 23) == [2, 3, 5, 7, 11, 13, 17, 19, 23])

    /// https://www.mathematical.com/primes0to1000k.html
    //#expect(primeNumbersUpTo(1_000_000).count == 78498)
  }

  @available(iOS 15.0, *)
  @Test func speedTestPrimeNumbers() async throws {
    // speed test between .isPrime and .isPrime2
    let testNumbers = 2000...6000
    let list = testNumbers.lazy.map { $0 }
    let startTime1 = CFAbsoluteTimeGetCurrent()
    for number in list {
      let _ = primeNumbersUpTo(number)
    }
    let endTime1 = CFAbsoluteTimeGetCurrent()
    for number in list {
      let _ = primeNumbers(through: number)
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
    let longFullList = [(1, false), (2, true), (3, true), (4, false), (5, true), (6, false), (7, true), (8, false), (9, false), (10, false), (11, true), (12, false), (13, true), (14, false), (15, false), (16, false), (17, true), (18, false), (19, true), (20, false), (21, false), (22, false), (23, true), (24, false), (25, false), (26, false), (27, false), (28, false), (29, true), (30, false), (31, true), (32, false), (33, false), (34, false), (35, false), (36, false), (37, true), (38, false), (39, false), (40, false), (41, true), (42, false), (43, true), (44, false), (45, false), (46, false), (47, true), (48, false), (49, false), (50, false), (51, false), (52, false), (53, true), (54, false), (55, false), (56, false), (57, false), (58, false), (59, true), (60, false), (61, true), (62, false), (63, false), (64, false), (65, false), (66, false), (67, true), (68, false), (69, false), (70, false), (71, true), (72, false), (73, true), (74, false), (75, false), (76, false), (77, false), (78, false), (79, true), (80, false), (81, false), (82, false), (83, true), (84, false), (85, false), (86, false), (87, false), (88, false), (89, true), (90, false), (91, false), (92, false), (93, false), (94, false), (95, false), (96, false), (97, true), (98, false), (99, false), (100, false), (101, true), (102, false), (103, true), (104, false), (105, false), (106, false), (107, true), (108, false), (109, true), (110, false), (111, false), (112, false), (113, true), (114, false), (115, false), (116, false), (117, false), (118, false), (119, false), (120, false), (121, false), (122, false), (123, false), (124, false), (125, false), (126, false), (127, true), (128, false), (129, false), (130, false), (131, true), (132, false), (133, false), (134, false), (135, false), (136, false), (137, true), (138, false), (139, true), (140, false), (141, false), (142, false), (143, false), (144, false), (145, false), (146, false), (147, false), (148, false), (149, true), (150, false), (151, true), (152, false), (153, false), (154, false), (155, false), (156, false), (157, true), (158, false), (159, false), (160, false), (161, false), (162, false), (163, true), (164, false), (165, false), (166, false), (167, true), (168, false), (169, false), (170, false), (171, false), (172, false), (173, true), (174, false), (175, false), (176, false), (177, false), (178, false), (179, true), (180, false), (181, true), (182, false), (183, false), (184, false), (185, false), (186, false), (187, false), (188, false), (189, false), (190, false), (191, true), (192, false), (193, true), (194, false), (195, false), (196, false), (197, true), (198, false), (199, true), (200, false)]

    for number in (2...200).map({ $0 }) {
      let test = (number, number.isPrime)
      print(test.1 ? "\(test.0) is prime" : "\(test.0) is composite")
      #expect(number < 200 ? test == longFullList[number-1] : true)
    }

    // speed test between .isPrime and .isPrime2
    let testNumbers = 2...10000
    let list = testNumbers.map { $0 }
    let startTime1 = CFAbsoluteTimeGetCurrent()
    for number in list {
      let _ = number.isPrime
    }
    let endTime1 = CFAbsoluteTimeGetCurrent()
    for number in list {
      let _ = number.isPrime2
    }
    let endTime2 = CFAbsoluteTimeGetCurrent()
    let totalElapsed1 = endTime1 - startTime1
    let totalElapsed2 = endTime2 - endTime1

    print("totalElapsed1:", totalElapsed1.formatted())
    print("totalElapsed2:", totalElapsed2.formatted())
    print("Int.isPrime is faster than Int.isPrime2 by:",
          ((totalElapsed2 - totalElapsed1)/totalElapsed1).formatted(), "x")
  }

  @Test func largestPrime() async throws {
    var record: [Double] = []
    for testNumber in stride(from: 2, through: 30, by: 1) {
      let largestPrime = testNumber.largestPrime
      record.append(Double((testNumber/largestPrime)))
      //print("largestPrimeFactor of \(testNumber) is: ", largestPrime)
    }
    //print(record)
    #expect(record == [1.0, 1.0, 2.0, 1.0, 2.0, 1.0, 4.0, 3.0, 2.0, 1.0, 4.0, 1.0, 2.0, 3.0, 8.0, 1.0, 6.0, 1.0, 4.0, 3.0, 2.0, 1.0, 8.0, 5.0, 2.0, 9.0, 4.0, 1.0, 6.0])
  }

  @Test func smallestPrime() async throws {
    var record: [Double] = []
    for testNumber in stride(from: 2, through: 30, by: 1) {
      let smallestPrime = testNumber.smallestPrime
      record.append(Double((testNumber/smallestPrime)))
      //print("smallestPrimeFactor of \(testNumber) is: ", smallestPrime)
    }
    //print(record)
    #expect(record == [1.0, 1.0, 2.0, 1.0, 3.0, 1.0, 4.0, 3.0, 5.0, 1.0, 6.0, 1.0, 7.0, 5.0, 8.0, 1.0, 9.0, 1.0, 10.0, 7.0, 11.0, 1.0, 12.0, 5.0, 13.0, 9.0, 14.0, 1.0, 15.0])
  }

  @Test func testAllFactors() async throws {
    let testNumber = 66
    let allFactors = allFactors(of: testNumber)
    print("allFactors", allFactors)
    //print("primeFactors", testNumber.primeFactors)
    let passed = (allFactors == [1, 2, 3, 6, 11, 22, 33, 66])
    //print(passed ? "allFactors passed" : "allFactors not passed")
    #expect(passed)
  }



  @Test func FactorsCache() async throws {
    let testNumbers = 2...200
    // check all numbers less than testNumber (for complete check)
    let keys = testNumbers.map { $0 }
    let values = keys.map { $0.primeFactors }
    let dict = Dictionary(uniqueKeysWithValues: zip(keys, values))
    print(dict)
  }

  @Test func primeNumbers2() async throws {
    let testSet = (0...149).map { $0 }
    let windowSize = 18
    for test in testSet {
      let primes = primeNumbers(from: test, through: test+windowSize)
      print(test, "to", test+windowSize, primes)
    }
  }

  @Test func iteratorTest() async throws {
    let krell = PrimeIteratorSequence(from: 0, through: 105)

    for val in krell {
      print(val)
    }
  }

}
