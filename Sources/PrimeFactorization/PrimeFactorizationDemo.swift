//
//  PrimeFactorizationDemo.swift
//  PrimeFactorization
//
//  Demonstrates usage of the prime factorization functions.
//

import Foundation

@available(macOS 10.15, *)
public func demonstratePrimeFactorization() async {
    do {
        print("Computing prime factors...\n")
        // Single number factorization
        let number = Int.max
        let factors = try await primeFactors(of: number)
        print("Single threaded: \(number) = \(factors.primeFactorizationString)")
        print("Simple array: \(number) = \(factors.simpleArrayDescription)\n")

        // Multiple numbers concurrently
        let numbers = [101, 1001, 1234, 2234, 3234]
        let results = try await primeFactorsConcurrent(of: numbers)
        for (num, factors) in results.sorted(by: { $0.key < $1.key }) {
            print("\(num) = \(factors.simpleArrayDescription)")
        }
        print()

        // Using optimized version for large numbers
        let largeNumber = Int.max
        let optimizedFactors = try await primeFactorsOptimized(of: largeNumber)
        print("Optimized: \(largeNumber) = \(optimizedFactors.simpleArrayDescription)")
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}
