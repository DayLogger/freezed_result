import 'dart:async';

import 'package:collection/collection.dart' show DeepCollectionEquality;
import 'package:meta/meta.dart' show optionalTypeArgs;

part '_failure.dart';
part '_mixin.dart';
part '_success.dart';

/// Represents the output of an action that can succeed or
/// fail. Holds a `value` on [success] and an `error` on
/// [failure].
///
/// ```dart
/// Result<Person, ApiFailure> fetchPerson(int id) {}
/// ```
///
/// Use [Nothing] for outputs that still succeed or fail,
/// but have no meaningful success [value].
///
/// ```dart
/// Result<Nothing, DatabaseError> vacuumDatabase() {}
/// ```
///
/// ### Processing Values and Errors
///
/// Process the values by handling both [success] and
/// [failure] cases using [when].
///
/// ```dart
/// final result = fetchPerson(12);
/// result.when(
///   success: (person) => state = MyState.personFound(person);
///   failure: (error) => state = MyState.error(error);
/// );
/// ```
///
/// Or create a common type from both cases, also using
/// [when].
///
/// ```dart
/// final result = fetchPerson(12);
/// final description = result.when(
///   success: (person) => 'Found Person ${person.id}';
///   failure: (error) => 'Problem finding a person.';
/// );
/// ```
///
/// Or ignore the error and do something with [maybeValue].
///
/// ```dart
/// final person = result.maybeValue;
/// if (person != null) {}
/// ```
///
/// Or use exception handling to process both [success] and
/// [failure] cases.
///
/// ```dart
/// try {
///   final person = result.valueOrThrow();
/// } on ApiFailure catch(e) {
///   // handle ApiFailure
/// }
/// ```
///
/// ### Failure Type Requirements
///
/// [Failure] types must not be nullable so they _can_ be
/// thrown, but they are not _intended_ to be thrown. Use
/// the type that best fits your app.
///
/// We recommend transforming lower-level error types into
/// higher level failure types. This makes app-level logic
/// cleaner and makes UI rendering more consistent.
///
/// ### Creating Results
///
/// Create the result with named constructors [success] and
/// [failure].
///
/// ```dart
/// Future<Result<Person, ApiFailure>> fetchPerson(int id) async {
///   try {
///     final person = await api.getPerson(12);
///     return Result.success(person);
///   } on TimeoutException {
///     return Result.failure(ApiFailure.timeout());
///   } on FormatException {
///     return Result.failure(ApiFailure.invalidData());
///   }
/// }
/// ```
///
/// Use [nothing] for a result with no meaningful success
/// [value]. It is the constant singleton instance of
/// [Nothing].
///
/// ```dart
/// Result<Nothing, DatabaseError> vacuumDatabase() {
///   try {
///     db.vacuum();
///     return Result.success(nothing);
///   } on DatabaseError catch(e) {
///     return Result.failure(e);
///   }
/// }
/// ```
///
/// ### Transforming Results
///
/// Process and transform this [Result] into another
/// [Result] as part of a pipeline using [map].
///
/// ```dart
/// Result<DateTime, ApiFailure> bigDay = fetchPerson(12).map((person) => person.birthday);
/// ```
abstract class Result<Success, Failure extends Object>
    with _$Result<Success, Failure> {
  const Result._();

  /// Create a [success]ful [Result], and store [value] for
  /// later use.
  const factory Result.success(Success value) =
      _SuccessResult<Success, Failure>;

  /// Create a [failure] [Result], and save [error] for
  /// later processing.
  const factory Result.failure(Failure error) =
      _FailureResult<Success, Failure>;

  /// Creates a [success] result from the return value of an
  /// _async_ [closure]. Without an explicit type
  /// parameters, any object thrown by [closure] is caught
  /// and returned in a [failure] result. Specifying the
  /// type parameters will catch only objects of type [E].
  /// All others continue uncaught. To specify [E] Dart
  /// requires that you also specify [T].
  static FutureOr<Result<T, E>> catching<T, E extends Object>(
      FutureOr<T> Function() closure) async {
    try {
      final value = await closure();
      return Result.success(value);
    } on E catch (e) {
      return Result.failure(e);
    }
  }

  /// `true` if the result is a [success], `false`
  /// otherwise.
  bool get isSuccess;

  /// `true` if the result is a [failure], `false`
  /// otherwise.
  bool get isFailure => !isSuccess;

  /// Returns the [value] for [success] and `null` for
  /// [failure].
  ///
  /// Prefer using [when].
  ///
  /// Warning: if the [Success] type is nullable, you won't
  /// be able to tell the difference between a [success]
  /// `null` and a [failure].
  Success? get maybeValue;

  /// Returns the [error] for [failure] and `null` for
  /// [success].
  Failure? get maybeError;

  /// Returns the [value] for [success] and `throw`s the
  /// [error] on [failure].
  ///
  /// Prefer using [when].
  Success valueOrThrow();
}
