/// A class with no fields and no public constructor. Used
/// with [Result] when `success` or `failure` has no value
/// at all. The singleton instance is exposed as `nothing`.
///
/// ```dart
/// final Result<Nothing, Error> voidResult = Result.success(nothing);
/// ```
class Nothing {
  const Nothing._();
}

/// The global instance of [Nothing], representing no value at all.
const nothing = Nothing._();
