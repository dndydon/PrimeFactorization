//
//  PrimeFactorizationDemo.swift
//  PrimeFactorization
//
//  Demonstrates usage of the prime factorization functions.

import Foundation

/// Demonstrates various prime factorization features.
/// Called by PrimeFactorizationTests file
///
/// This function showcases:
/// - Single number factorization
/// - Concurrent factorization of multiple numbers
/// - Formatted output using array extensions
@available(macOS 10.15, iOS 15.0, *)
public func demonstratePrimeFactorization() async {
  do {
    print("Prime Factorization Demo\n")
    print("=" + String(repeating: "=", count: 50))
    
    // Single number factorization
    print("\n1. Single Number Factorization")
    print("-" + String(repeating: "-", count: 50))
    let number = 5040
    let factors = number.primeFactors
    print("\(number) = \(factors.primeFactorizationString)")
    print("Factors: \(factors.simpleArrayDescription)\n")
    
    // Multiple numbers concurrently
    print("2. Concurrent Factorization")
    print("-" + String(repeating: "-", count: 50))
    let numbers = [101, 1001, 1234, 2234, 3234]
    let results = try await primeFactorsConcurrent(of: numbers)
    for (num, factors) in results.sorted(by: { $0.key < $1.key }) {
      print("\(num) = \(factors.primeFactorizationString)")
    }
    
    // Large number
    print("\n3. Large Number Factorization")
    print("-" + String(repeating: "-", count: 50))
    let largeNumber = 987654321
    let largeFactors = largeNumber.primeFactors
    print("\(largeNumber) = \(largeFactors.primeFactorizationString)")
    print("Factors: \(largeFactors.simpleArrayDescription)\n")
    
    print("=" + String(repeating: "=", count: 50))
    print("Demo completed successfully!")
    
  } catch {
    print("Error: \(error)")
    if let pfError = error as? PrimeFactorizationError {
      switch pfError {
      case .invalidInput(let msg):
        print("Invalid input: \(msg)")
      case .rangeTooLarge(let size):
        print("Range too large: \(size)")
      }
    }
  }
}


/// Called by PrimeFactorizationTests file
@available(macOS 12.0, iOS 15.0, *)
func benchmarkPrimeGeneration() async {
  let testRanges = [
    ("Small (100K)", 2, 100_000),
    ("Medium (500K)", 2, 500_000),
    ("Large (1M)", 2, 1_000_000),
    ("Very Large (5M)", 2, 5_000_000),
    ("Max Default (15M)", 2, 15_000_000),
  ]

  print("Prime Generation Benchmark")
  print("=" + String(repeating: "=", count: 70))
  print("Note: Temporarily increasing maxPrimeRange for benchmarking...\n")
  
  let originalMax = PrimeFactorizationConfig.shared.maxPrimeRange
  PrimeFactorizationConfig.shared.maxPrimeRange = 200_000_000

  for (label, start, end) in testRanges {
    let rangeSize = end - start

    let startTime = CFAbsoluteTimeGetCurrent()
    let startMemory = reportMemory()

    do {
      let primes = try primeNumbers(from: start, through: end)

      let endTime = CFAbsoluteTimeGetCurrent()
      let endMemory = reportMemory()
      let elapsed = endTime - startTime
      let memoryDelta = endMemory - startMemory

      print("\n\(label)")
      print("  Range: \(rangeSize.formatted()) (\(start.formatted())...\(end.formatted()))")
      print("  Primes found: \(primes.count.formatted())")
      print("  Time: \(String(format: "%.2f", elapsed)) seconds")
      print("  Memory delta: \(String(format: "%.2f", Double(memoryDelta) / 1024 / 1024)) MB")
      print("  Throughput: \(String(format: "%.0f", Double(rangeSize) / elapsed)) numbers/sec")

      let rating = elapsed < 1.0 ? "Excellent" :
      elapsed < 3.0 ? "Good" :
      elapsed < 10.0 ? "Acceptable" :
      "Too Slow"
      print("  Rating: \(rating)")

    } catch {
      print("\n\(label): Error - \(error)")
    }
  }

  PrimeFactorizationConfig.shared.maxPrimeRange = originalMax
  print("\n" + String(repeating: "=", count: 70))
  print("Restored maxPrimeRange to \(originalMax.formatted())")
}

func reportMemory() -> UInt64 {
  var info = mach_task_basic_info()
  var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

  let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
      task_info(mach_task_self_,
                task_flavor_t(MACH_TASK_BASIC_INFO),
                $0,
                &count)
    }
  }

  return kerr == KERN_SUCCESS ? info.resident_size : 0
}
