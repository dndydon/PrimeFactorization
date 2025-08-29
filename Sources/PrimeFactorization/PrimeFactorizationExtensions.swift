//
//  PrimeFactorizationExtensions.swift
//  PrimeFactorization
//
//  Extensions for formatting prime factor arrays.
//

import Foundation

public extension Array where Element == Int {

    /// Returns a string representation like: [2, 2, 3]
    var simpleArrayDescription: String {
        "[" + self.map(String.init).joined(separator: ", ") + "]"
    }

    /// Returns a string representation of prime factorization, e.g.: 2^3 × 3^2 × 5
    var primeFactorizationString: String {
        let factorCounts = self.reduce(into: [:]) { counts, factor in
            counts[factor, default: 0] += 1
        }
        return factorCounts
            .sorted { $0.key < $1.key }
            .map { factor, count in
                count == 1 ? "\(factor)" : "\(factor)^\(count)"
            }
            .joined(separator: " × ")
    }
}
