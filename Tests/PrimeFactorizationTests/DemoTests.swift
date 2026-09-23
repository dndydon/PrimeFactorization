import Testing
import Foundation
@testable import PrimeFactorization

extension Tag {
    @Tag static var benchmark: Self
}

@Suite("Demo and benchmark")
struct DemoTests {

    @available(macOS 10.15, iOS 15.0, *)
    @Test func demonstrationRuns() async {
        await demonstratePrimeFactorization()
    }

    /// Opt-in: `PF_BENCHMARKS=1 swift test --filter DemoTests`.
    /// It temporarily raises the shared `maxPrimeRange`, so it stays out of normal parallel runs.
    @available(macOS 12.0, iOS 15.0, *)
    @Test(
        .tags(.benchmark),
        .enabled(if: ProcessInfo.processInfo.environment["PF_BENCHMARKS"] != nil, "Set PF_BENCHMARKS=1 to run")
    )
    func primeGenerationBenchmark() async {
        await benchmarkPrimeGeneration()
    }
}
