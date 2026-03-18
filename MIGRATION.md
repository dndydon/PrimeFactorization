# Migration Guide: Consolidating PrimeFactorization2

## Date: March 16, 2026

This document describes the consolidation of `PrimeFactorization2.swift` into the main `PrimeFactorization.swift` file to resolve namespace conflicts.

---

## Summary of Changes

### ✅ Files Merged
- **PrimeFactorization2.swift** → merged into **PrimeFactorization.swift**
- **PrimeFactorizationExtensions.swift** → merged into **PrimeFactorization.swift**

### 📝 Files Updated
- **PrimeFactorization.swift** - Added async functions and array extensions
- **PrimeFactorizationDemo.swift** - Updated to use consolidated API
- **PrimeFactorizationTests2.swift** - Fixed error handling
- **README.md** - Documented async/await APIs

---

## Namespace Conflicts Resolved

### Error Enum Duplication

**Before (Conflicting Definitions):**

In `PrimeFactorization.swift`:
```swift
public enum PrimeFactorizationError: Error, Equatable {
  case invalidInput(String)
  case rangeTooLarge(Int)
}
```

In `PrimeFactorization2.swift`:
```swift
public enum PrimeFactorizationError: Error, LocalizedError {
  case invalidNumber
}
```

**After (Unified Definition):**
```swift
public enum PrimeFactorizationError: Error, Equatable {
  case invalidInput(String)
  case rangeTooLarge(Int)
}
```

The unified error enum uses associated values for better error messages.

---

## API Consolidation

### New Async Functions (Added to Main File)

All async functions now use the unified `PrimeFactorizationError`:

```swift
// Basic async version
public func primeFactors(of: Int) async throws -> [Int]

// Optimized async version  
public func primeFactorsOptimized(of: Int) async throws -> [Int]

// Concurrent version
public func primeFactorsConcurrent(of: [Int]) async throws -> [Int: [Int]]
```

### Array Extensions (Added to Main File)

```swift
extension Array where Element == Int {
  var simpleArrayDescription: String
  var primeFactorizationString: String  
}
```

---

## Migration for Existing Code

### If You Were Using PrimeFactorization2

#### Error Handling

**Before:**
```swift
do {
  let factors = try await primeFactors(of: -1)
} catch {
  if error == .invalidNumber {
    print("Invalid")
  }
}
```

**After:**
```swift
do {
  let factors = try await primeFactors(of: -1)
} catch {
  if case .invalidInput(let msg) = error as? PrimeFactorizationError {
    print("Invalid: \(msg)")
  }
}
```

#### Function Calls (No Change)

All async function calls remain the same:
```swift
// ✅ Still works exactly the same
let factors = try await primeFactors(of: 12345)
let optimized = try await primeFactorsOptimized(of: 5040)
let concurrent = try await primeFactorsConcurrent(of: [12, 18, 24])
```

---

## What's Different?

### Error Messages Are More Descriptive

**Before:**
```
Error: invalidNumber
```

**After:**
```
Error: Number must be greater than 1, got -5
```

### Consistent Error Types

All functions now use the same error enum, making error handling consistent across the entire API.

---

## Testing the Migration

### Run Tests
```bash
swift test
```

### Expected Results
- All tests in `PrimeFactorizationTests.swift` should pass
- All tests in `PrimeFactorizationTests2.swift` should pass
- No build errors about duplicate definitions

---

## Benefits of This Consolidation

1. **✅ No More Namespace Conflicts** - Single source of truth for error types
2. **✅ Better Documentation** - All APIs documented in one place
3. **✅ Easier Maintenance** - One file to update instead of multiple
4. **✅ Cleaner API** - Consistent error handling across all functions
5. **✅ Better Error Messages** - Associated values provide context

---

## Performance Notes

No performance changes - the async algorithms are identical to the PrimeFactorization2 versions, just relocated.

---

## Support

If you encounter any issues after migration:
1. Check that you're using the correct error enum cases (`.invalidInput` instead of `.invalidNumber`)
2. Verify all imports reference `PrimeFactorization` (not `PrimeFactorization2`)
3. Ensure tests are using `try await` for async functions

---

## Version History

- **v1.0** - Initial separate implementations
- **v2.0** - Consolidated into single file (this migration)
