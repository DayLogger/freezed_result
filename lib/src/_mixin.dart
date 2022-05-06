part of 'result.dart';

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

mixin _$Result<Success, Failure extends Object> {
  /// This is the primary way to work with the [value] and
  /// [error] in a [Result]. Provide a [success] function
  /// which will process the [value] when the [Result] was
  /// successful, and a [failure] function which will
  /// process the [error] when the [Result] is a failure.
  ///
  /// Process both [success] and [failure] with different
  /// logic:
  ///
  /// ```dart
  /// final result = fetchPerson(12);
  /// result.when(
  ///   success: (value) => state = MyState.personFound(value);
  ///   failure: (error) => state = MyState.error(error);
  /// );
  /// ```
  ///
  /// Or create a common type from both cases by returning
  /// the same type and capturing the return value of
  /// [when].
  ///
  /// ```dart
  /// final result = fetchPerson(12);
  /// final description = result.when(
  ///   success: (value) => 'Found Person ${person.id}';
  ///   failure: (error) => 'Problem finding a person.';
  /// );
  /// ```
  ///
  /// Or use [Nothing] to trigger success processing even
  /// when there is no meaningful [value].
  ///
  /// ```dart
  /// final Result<Nothing, DatabaseError> result = await vacuumDatabase();
  /// result.when(
  ///   success: (_) => _notify('All clean!');
  ///   failure: (error) {
  ///     _log(error);
  ///     _recoverFromBackup();
  ///   },
  /// );
  /// ```
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Success value) success,
    required TResult Function(Failure error) failure,
  }) {
    throw _privateConstructorUsedError;
  }

  /// When this [Result] is a success, [transform] the
  /// [value] into a new value, and wrap the new value in a
  /// [Result.success]. When this [Result] is a [failure],
  /// simply return the failure as-is.
  ///
  /// After the transformation, `isSuccess` will be
  /// identical between the new and old [Result]s—the
  /// transform doesn't change the nature of the outcome,
  /// only the type.
  ///
  /// A [Result.success] will always transform to a
  /// [Result.success].
  ///
  /// A [Result.failure] will always transform to a
  /// [Result.failure].
  ///
  /// It's most useful for allowing errors to propagate
  /// untouched, while processing success values in a
  /// pipeline.
  ///
  /// ```dart
  /// Result<Person, ApiFailure> fetchPerson(int id) {
  ///   // ...
  /// }
  /// Result<DateTime, ApiFailure> bigDay = fetchPerson(12).map((person) => person.birthday);
  /// ```
  @optionalTypeArgs
  Result<NewSuccess, Failure> map<NewSuccess>(
    NewSuccess Function(Success value) transform,
  ) =>
      when(
        success: (value) => Result.success(transform(value)),
        failure: (error) => Result.failure(error),
      );

  /// When this [Result] is a success, simply return the
  /// [value] as-is. When this [Result] is a [failure],
  /// [transform] the [error] into a new error, and wrap the
  /// new error in a [Result.failure].
  ///
  /// After the transformation, `isSuccess` will be
  /// identical between the new and old [Result]s—the
  /// transform doesn't change the nature of the outcome,
  /// only the type.
  ///
  /// A [Result.success] will always transform to a
  /// [Result.success].
  ///
  /// A [Result.failure] will always transform to a
  /// [Result.failure].
  ///
  /// Most useful for turning raw [Error]s into [Freezed
  /// Unions](https://pub.dev/packages/freezed#union-types-and-sealed-classes)
  /// for describing failures.
  ///
  /// ```dart
  /// Result<Person, ApiError> apiPerson(int id) {
  ///   final Result<Person, DioError> raw = await dioGetApiPerson(12);
  ///   return raw.mapError((error) => _interpretDioError(error));
  /// }
  /// ```
  @optionalTypeArgs
  Result<Success, NewFailure> mapError<NewFailure extends Object>(
    NewFailure Function(Failure error) transform,
  ) =>
      when(
        success: (value) => Result.success(value),
        failure: (error) => Result.failure(transform(error)),
      );

  /// When this [Result] is a success, [transform] the
  /// [value] into a new value, and wrap the new value in a
  /// [Result.success]. When this [Result] is a [failure],
  /// [transform] the [error] into a new error, and wrap the
  /// new error in a [Result.failure].
  ///
  /// After the transformation, `isSuccess` will be
  /// identical between the new and old [Result]s—the
  /// transform doesn't change the nature of the outcome,
  /// only the type.
  ///
  /// A [Result.success] will always transform to a
  /// [Result.success].
  ///
  /// A [Result.failure] will always transform to a
  /// [Result.failure].
  ///
  /// Uncommon, but allows a single step of the pipeline to
  /// change both the [value]s and the [error]s.
  ///
  /// ```dart
  /// Result<Person, DioError> fetchPerson(int id) {
  ///   // ...
  /// }
  /// Result<String, ApiFailure> fullName = fetchPerson(12).mapWhen(
  ///     success: (person) => _sanitize(person.firstName, person,lastName),
  ///     failure: (error) => _interpretDioError(error),
  /// );
  /// ```
  @optionalTypeArgs
  Result<NewSuccess, NewFailure>
      mapWhen<NewSuccess, NewFailure extends Object>({
    required NewSuccess Function(Success value) success,
    required NewFailure Function(Failure error) failure,
  }) =>
          when(
            success: (value) => Result.success(success(value)),
            failure: (error) => Result.failure(failure(error)),
          );

  /// When this [Result] is a success, [transform] the
  /// [value] into a new [Result]. When this [Result] is a
  /// [failure], simply return the failure as-is.
  ///
  /// After the transformation, `isSuccess` may be different
  /// between the new and old [Result]s—the transform IS
  /// allowed to change the nature of the outcome.
  ///
  /// A [Result.success] may transform to either a
  /// [Result.success] or a [Result.failure].
  ///
  /// A [Result.failure] will always transform to a
  /// [Result.failure].
  ///
  /// Most useful for processing the successful [value]
  /// using another operation which may fail with the same
  /// type [Failure].
  ///
  /// ```dart
  /// final Result<Person, FormatError> personResult = parsePerson(jsonString);
  /// final Result<DateTime, FormatError> bigDay = personResult.mapToResult(
  ///   (person) => parse(person.birthDateString),
  /// );
  /// ```
  ///
  /// Parsing the `Person` may succeed, but parsing the
  /// `DateTime` may fail. In that case, an initial
  /// [success] is transformed into a [failure].
  @optionalTypeArgs
  Result<NewSuccess, Failure> mapToResult<NewSuccess>(
    Result<NewSuccess, Failure> Function(Success value) transform,
  ) =>
      when(
        success: (value) => transform(value),
        failure: (error) => Result.failure(error),
      );

  /// When this [Result] is a success, simply return the
  /// [value] as-is. When this [Result] is a [failure],
  /// [transform] the [error] into a new [Result].
  ///
  /// After the transformation, `isSuccess` may be different
  /// between the new and old [Result]s—the transform IS
  /// allowed to change the nature of the outcome.
  ///
  /// A [Result.success] will always transform to a
  /// [Result.success].
  ///
  /// A [Result.failure] may transform to either a
  /// [Result.success] or a [Result.failure].
  ///
  /// Useful to recover from some [error]s by returning a
  /// [success] value when a workaround exists. The value
  /// must match the success type, but the error type can
  /// change.
  ///
  /// Here, [mapErrorToResult] is used to ignore errors
  /// which can be resolved by a cache lookup. Both
  /// unrecoverable `DioError`s and internal errors
  /// accessing the cache are expressed in the more generic
  /// `FetchError` of the final output.
  ///
  /// ```dart
  /// final Result<Person, DioError> raw = await dioGetApiPerson(id);
  /// final Result<Person, FetchError> output = raw.mapErrorToResult((error) => _getPersonCache(id));
  ///
  /// Result<Person, FetchError> _getPersonCache(int id) {
  ///   // ...
  /// }
  /// ```
  ///
  /// Here, an initial [failure] is transformed into a
  /// [success] whenever the required value is available in
  /// the local cache.
  @optionalTypeArgs
  Result<Success, NewFailure> mapErrorToResult<NewFailure extends Object>(
    Result<Success, NewFailure> Function(Failure error) transform,
  ) =>
      when(
        success: (value) => Result.success(value),
        failure: (error) => transform(error),
      );

  /// When this [Result] is a success, [transform] the
  /// [value] into a new [Result]. When this [Result] is a
  /// [failure], [transform] the [error] into a new
  /// [Result].
  ///
  /// After the transformation, `isSuccess` may be different
  /// between the new and old [Result]s—the transform IS
  /// allowed to change the nature of the outcome.
  ///
  /// A [Result.success] may transform to either a
  /// [Result.success] or a [Result.failure].
  ///
  /// A [Result.failure] may transform to either a
  /// [Result.success] or a [Result.failure].
  ///
  /// Both transforms must agree on the [NewSuccess] and
  /// [NewFailure] types.
  ///
  /// Uncommon, but allows a single step of the pipeline to
  /// both try another operation on a success [value] which
  /// may fail in a new way with a new [error] type, and to
  /// translate any original [error] into the new type of
  /// [Failure].
  ///
  /// ```dart
  /// Result<Person, DioError> fetchPerson(int id) {
  ///   // ...
  /// }
  /// Result<String, ProcessingError> fullName = fetchPerson(12).mapToResultWhen(
  ///     success: (person) => _fullName(person.firstName, person,lastName),
  ///     failure: (dioError) => _asProcessingError(dioError),
  /// );
  /// ```
  @optionalTypeArgs
  Result<NewSuccess, NewFailure>
      mapToResultWhen<NewSuccess, NewFailure extends Object>({
    required Result<NewSuccess, NewFailure> Function(Success value) success,
    required Result<NewSuccess, NewFailure> Function(Failure error) failure,
  }) =>
          when(
            success: (value) => success(value),
            failure: (error) => failure(error),
          );

  /// See [mapToResult]. Aliased for Swift newcomers.
  @optionalTypeArgs
  Result<NewSuccess, Failure> flatMap<NewSuccess>(
    Result<NewSuccess, Failure> Function(Success value) transform,
  ) =>
      mapToResult(transform);

  /// See [mapErrorToResult]. Aliased for Swift newcomers.
  @optionalTypeArgs
  Result<Success, NewFailure> flatMapError<NewFailure extends Object>(
    Result<Success, NewFailure> Function(Failure error) transform,
  ) =>
      mapErrorToResult(transform);

  /// See [mapToResultWhen]. Aliased for Swift newcomers.
  @optionalTypeArgs
  Result<NewSuccess, NewFailure>
      flatMapWhen<NewSuccess, NewFailure extends Object>({
    required Result<NewSuccess, NewFailure> Function(Success value) success,
    required Result<NewSuccess, NewFailure> Function(Failure error) failure,
  }) =>
          mapToResultWhen(success: success, failure: failure);
}