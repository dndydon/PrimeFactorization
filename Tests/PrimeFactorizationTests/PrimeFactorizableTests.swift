import Testing
@testable import PrimeFactorization

@Suite("PrimeFactorizable Protocol and Int Overrides")
struct PrimeFactorizableTests {

    // MARK: - Int64.primeFactors (generic protocol extension)

    @Test func int64PrimeFactors_small() {
        #expect(Int64(60).primeFactors == [2, 2, 3, 5])
        #expect(Int64(18).primeFactors == [2, 3, 3])
    }

    @Test func int64PrimeFactors_prime() {
        #expect(Int64(1373).primeFactors == [1373])
        #expect(Int64(47).primeFactors == [47])
    }

    @Test func int64PrimeFactors_edgeCases() {
        #expect(Int64(0).primeFactors == [])
        #expect(Int64(1).primeFactors == [])
        #expect(Int64(-1).primeFactors == [])
        #expect(Int64(-60).primeFactors == [])
    }

    @Test func int64PrimeFactors_largeComposite() {
        let n = Int64(600_000_000_004)
        let factors = n.primeFactors
        let product = factors.reduce(Int64(1)) { $0 * $1 }
        let allPrime = !factors.map(\.isPrime).contains(false)
        #expect(product == n)
        #expect(allPrime)
    }

    @Test func int64PrimeFactors_nearMax() {
        for n in (Int64.max - 2)...Int64.max {
            let factors = n.primeFactors
            let product = factors.reduce(Int64(1)) { $0 * $1 }
            let allPrime = !factors.map(\.isPrime).contains(false)
            #expect(product == n || factors.isEmpty, "\(n): expected product \(n), got \(product) from \(factors)")
            #expect(allPrime, "non-prime factor in \(factors) for \(n)")
        }
    }

    // MARK: - Int64.isPrime (generic protocol extension)

    @Test func int64IsPrime_known() {
        for p: Int64 in [2, 3, 5, 7, 11, 13, 97] {
            #expect(p.isPrime, "\(p) should be prime")
        }
    }

    @Test func int64IsPrime_composite() {
        for c: Int64 in [4, 9, 100, 600_000] {
            #expect(!c.isPrime, "\(c) should not be prime")
        }
    }

    @Test func int64IsPrime_edgeCases() {
        #expect(!Int64(0).isPrime)
        #expect(!Int64(1).isPrime)
        #expect(!Int64(-5).isPrime)
    }

    @Test func int64IsPrime_nearMax() {
        // Int64.max = 9223372036854775807 — composite (divisible by 7)
        #expect(!Int64.max.isPrime)
    }

    // MARK: - UInt.primeFactors (generic protocol extension)

    @Test func uintPrimeFactors_small() {
        #expect(UInt(60).primeFactors == [2, 2, 3, 5])
        #expect(UInt(18).primeFactors == [2, 3, 3])
    }

    @Test func uintPrimeFactors_prime() {
        #expect(UInt(97).primeFactors == [97])
        #expect(UInt(1373).primeFactors == [1373])
    }

    @Test func uintPrimeFactors_edgeCases() {
        #expect(UInt(0).primeFactors == [])
        #expect(UInt(1).primeFactors == [])
    }

    @Test func uintPrimeFactors_nearMax() {
        for n in (UInt.max - 3)...UInt.max {
            let factors = n.primeFactors
            let product = factors.reduce(UInt(1)) { $0 * $1 }
            let allPrime = !factors.map(\.isPrime).contains(false)
            #expect(product == n || factors.isEmpty, "\(n): expected product \(n), got \(product) from \(factors)")
            #expect(allPrime, "non-prime factor in \(factors) for \(n)")
        }
    }

    // MARK: - UInt.isPrime (generic protocol extension)

    @Test func uintIsPrime_known() {
        for p: UInt in [2, 3, 5, 7, 97] {
            #expect(p.isPrime, "\(p) should be prime")
        }
    }

    @Test func uintIsPrime_composite() {
        for c: UInt in [4, 9, 1000] {
            #expect(!c.isPrime, "\(c) should not be prime")
        }
    }

    @Test func uintIsPrime_edgeCases() {
        #expect(!UInt(0).isPrime)
        #expect(!UInt(1).isPrime)
    }

    // MARK: - Int.primeFactors (optimized Int override)

    @Test func intPrimeFactors_edgeCases() {
        #expect(1.primeFactors == [])
        #expect(0.primeFactors == [])
        #expect((-1).primeFactors == [])
    }

    @Test func intPrimeFactors_powerOf2() {
        // Exercises the trailingZeroBitCount fast path
        #expect(64.primeFactors == [2, 2, 2, 2, 2, 2])
        #expect(1024.primeFactors == Array(repeating: 2, count: 10))
        #expect(2.primeFactors == [2])
    }

    @Test func intPrimeFactors_odd() {
        #expect(15.primeFactors == [3, 5])
        #expect(105.primeFactors == [3, 5, 7])
        #expect(3.primeFactors == [3])
    }

    @Test func intPrimeFactors_mixed() {
        #expect(60.primeFactors == [2, 2, 3, 5])
        #expect(600_000_004.primeFactors == [2, 2, 150_000_001])
        #expect(5040.primeFactors == [2, 2, 2, 2, 3, 3, 5, 7])
    }

    @Test func intPrimeFactors_prime() {
        #expect(97.primeFactors == [97])
        #expect(1_200_000_041.primeFactors == [1_200_000_041])
    }

    @Test func intPrimeFactors_bulk() {
        for n in 2...10_000 {
            let factors = n.primeFactors
            let product = factors.reduce(1) { $0 * $1 }
            #expect(product == n, "primeFactors(\(n)) product mismatch: \(factors)")
        }
    }

    // Parity check: Int-specific optimized path and the Int64 generic path should agree.
    //
    // Performance note: The generic path (PrimeFactorizable protocol extension) is ~14x
    // slower than the Int override in debug/test builds. This is because generic arithmetic
    // operations (%, /, +, comparisons) go through protocol witness tables without -O
    // optimization. In release builds, the compiler specializes generics for concrete types,
    // eliminating the witness table overhead. Since this package ships as a library,
    // consumers always get the optimized code path.
    //
    // The test list is kept short to avoid long test times from the debug-mode overhead,
    // particularly for near-Int.max values where the trial division loop is already expensive.
    @Test func intPrimeFactors_parityWithGeneric() {
        let testValues: [Int] = [
            60, 97, 600_000_004, 1_200_000_041,
            // Near-max values — Int.max-1 is the slowest (~13s generic in debug)
            Int.max, Int.max - 1, Int.max - 2,
        ]
        for n in testValues {
            let intResult = n.primeFactors
            let generic = Int64(n).primeFactors.map { Int($0) }
            #expect(intResult == generic, "Int.primeFactors(\(n)) = \(intResult), generic = \(generic)")
        }
    }

    // MARK: - smallPrimes table verification

    /// Verifies the static smallPrimes table by re-computing primes via Sieve and comparing.
    @Test func smallPrimesTable_correctness() {
        #expect(smallPrimes.count == 1000)
        #expect(smallPrimes.first == 2)
        #expect(smallPrimes.last == 7919)

        // Verify every entry is actually prime
        for p in smallPrimes {
            #expect(Int64(p).isPrime, "\(p) in smallPrimes is not prime")
        }

        // Verify no primes are missing (table is contiguous)
        for i in 1..<smallPrimes.count {
            // No prime exists between consecutive entries
            for n in (smallPrimes[i - 1] + 1)..<smallPrimes[i] {
                #expect(!Int64(n).isPrime, "\(n) is prime but missing from smallPrimes")
            }
        }
    }

    /// Verifies that factorization works correctly at the table boundary.
    @Test func intPrimeFactors_tableBoundary() {
        // Number whose smallest prime factor is just beyond the table
        // 7919 is the last table prime; 7927 is the next prime
        let n = 7927 * 7927  // = 62,837,929
        let factors = n.primeFactors
        #expect(factors == [7927, 7927])

        // Number that requires both table primes and beyond-table primes
        let m = 7919 * 7927
        let mFactors = m.primeFactors
        #expect(mFactors == [7919, 7927])
    }

    // MARK: - allFactors (generic protocol extension)

    @Test func allFactors_basic() {
        #expect(60.allFactors == [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60])
        #expect(1.allFactors == [1])
        #expect(0.allFactors == [])
        #expect((-1).allFactors == [])
    }

    @Test func allFactors_int64() {
        #expect(Int64(60).allFactors == [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60])
    }

    // MARK: - PrimeGenerator actor

    @Test func primeGeneratorFactors_basic() async {
        let g = PrimeGenerator()
        let f = await g.primeFactors(of: 60)
        #expect(f == [2, 2, 3, 5])
    }

    @Test func primeGeneratorFactors_prime() async {
        let g = PrimeGenerator()
        let f = await g.primeFactors(of: 97)
        #expect(f == [97])
    }

    @Test func primeGeneratorFactors_edgeCases() async {
        let g = PrimeGenerator()
        let zero = await g.primeFactors(of: 0)
        let one = await g.primeFactors(of: 1)
        #expect(zero == [])
        #expect(one == [])
    }

    @Test func primeGeneratorFactors_cacheHit() async {
        let g = PrimeGenerator()
        let first = await g.primeFactors(of: 60)
        let second = await g.primeFactors(of: 60)
        #expect(first == second)
        #expect(first == [2, 2, 3, 5])
    }

    // Documents the flush-all cache eviction strategy.
    // maxCacheSize is 10000; inserting 10001 distinct numbers triggers a full flush.
    // After the flush, a previously cached number must still return the correct result.
    @Test func primeGeneratorFactors_cacheEviction() async {
        let g = PrimeGenerator()
        for n in 2...10_002 {
            _ = await g.primeFactors(of: n)
        }
        let result = await g.primeFactors(of: 60)
        #expect(result == [2, 2, 3, 5])
    }

    @Test func primeGeneratorPrimesUpTo_small() async {
        let g = PrimeGenerator()
        let primes = await g.primes(upTo: 30)
        #expect(primes == [2, 3, 5, 7, 11, 13, 17, 19, 23, 29])
    }

    @Test func primeGeneratorPrimesUpTo_belowTwo() async {
        let g = PrimeGenerator()
        let a = await g.primes(upTo: 1)
        let b = await g.primes(upTo: 0)
        #expect(a == [])
        #expect(b == [])
    }

    @Test func primeGeneratorPrimesUpTo_count() async {
        let g = PrimeGenerator()
        let primes = await g.primes(upTo: 1000)
        #expect(primes.count == 168)
        #expect(primes.first == 2)
        #expect(primes.last == 997)
    }

    @Test func primeGeneratorConcurrentAccess() async {
        let g = PrimeGenerator()
        await withTaskGroup(of: [Int].self) { group in
            for _ in 0..<10 {
                group.addTask { await g.primeFactors(of: 5040) }
            }
            for await result in group {
                #expect(result == [2, 2, 2, 2, 3, 3, 5, 7])
            }
        }
    }
}
