# Freezed Result

A `Result<Success, Failure>` that feels like a Freezed union. It represents the output of an action that can succeed or fail. It holds either a `value` of type `Success` or an `error` of type `Failure`.

`Failure` can be any type, and it usually represents a higher abstraction than just `Error` or `Exception`. It's very common to use a [Freezed Union](https://pub.dev/packages/freezed#union-types-and-sealed-classes) for `Failure` (e.g. `AuthFailure`) with cases for the different kinds of errors that can occur (e.g. `AuthFailure.network`, `AuthFailure.storage`, `AuthFailure.validation`).

Because of this, we've made `Result` act a bit like a Freezed union (it has `when(success:, failure:)`), and the base class is generated from Freezed then we removed the parts that don't apply (`maybe*`) and adapted the others (`map*`) to feel more like a Result. We'll get into the details down below.

# Usage

There are 3 main ways to interact with a `Result`: process them, create them, and transform them.

## Processing Values and Errors

Process the values by handling both `success` and `failure` cases using `when`.

```dart
final result = fetchPerson(12);
result.when(
  success: (person) => state = MyState.personFound(person);
  failure: (error) => state = MyState.error(error);
);
```

Or create a common type from both cases, also using `when`.

```dart
final result = fetchPerson(12);
final description = result.when(
  success: (person) => 'Found Person ${person.id}';
  failure: (error) => 'Problem finding a person.';
);
```

Or ignore the error and do something with `maybeValue`, which returns `null` on failures.

```dart
final person = result.maybeValue;
if (person != null) {}
```

Or ignore both the value and the error by simply using the outcome.

```dart
if (result.isSuccess) {}
// elsewhere
if (result.isFailure) {}
```

Or throw `failure` cases and return `success` cases using `valueOrThrow`.

```dart
try {
  final person = result.valueOrThrow();
} on ApiFailure catch(e) {
  // handle ApiFailure
}
```

## Creating Results

Create the result with named constructors `Result.success` and `Result.failure`.

```dart
Result.success(person)
```

```dart
Result.failure(AuthFailure.network())
```

Declare both the `Success` and `Failure` types with typed variables or function return types.

```dart
Result<Person, AuthFailure> result = Result.success(person);
```

```dart
Result<Person, AuthFailure> result = Result.failure(AuthFailure.network());
```

```dart
Result<Person, FormatException> parsePerson(String json) {
  return Result.failure(FormatException());
}
```

`Result`s are really useful for `async` operations.

```dart
Future<Result<Person, ApiFailure>> fetchPerson(int id) async {
  try {
    final person = await api.getPerson(12);
    return Result.success(person);
  } on TimeoutException {
    return Result.failure(ApiFailure.timeout());
  } on FormatException {
    return Result.failure(ApiFailure.invalidData());
  }
}
```

Sometimes you have a function which may have errors, but returns `void` when successful. Variables can't be `void`, so use `Nothing` instead. The singleton instance is `nothing`.

```dart
Result<Nothing, DatabaseError> vacuumDatabase() {
  try {
    db.vacuum();
    return Result.success(nothing);
  } on DatabaseError catch(e) {
    return Result.failure(e);
  }
}
```

You can use `catching` to create a `success` result from the return value of an _async_ closure.

Without an explicit type parameters, any object thrown by the closure is caught and returned in a `failure` result. With type parameters, only that specific type will be caught. The rest will pass through uncaught.

```dart
final Result<String, Object> apiResult = await Result.catching(() => getSomeString());
```

```dart
final Result<String, FormatException> result = await Result.catching<String, FormatException>(
  () => formatTheThing(),
);
```

## Transforming Results

Process and transform this `Result` into another `Result` as needed.

### map

Change the type and value when the Result is a success. Leave the error untouched when it's a failure. Most useful for transformations of success data in a pipeline with steps that will never fail.

```dart
Result<DateTime, ApiFailure> bigDay = fetchPerson(12).map((person) => person.birthday);
```

### mapError

Change the error when the Result is a failure. Leave the value untouched when it's a success. Most useful for transforming low-level exceptions into more abstact failure classes which classify the exceptions.

```dart
Result<Person, ApiError> apiPerson(int id) {
  final Result<Person, DioError> raw = await dioGetApiPerson(12);
  return raw.mapError((error) => _interpretDioError(error));
}
```

### mapWhen

Change both the error and the value in one step. Rarely used.

```dart
Result<Person, DioError> fetchPerson(int id) {
  // ...
}
Result<String, ApiFailure> fullName = fetchPerson(12).mapWhen(
    success: (person) => _sanitize(person.firstName, person,lastName),
    failure: (error) => _interpretDioError(error),
);
```

### mapToResult

Use this to turn a success into either another success or to a compatible failure. Most useful when processing the success value with another operation which may itself fail.

```dart
final Result<Person, FormatError> personResult = parsePerson(jsonString);
final Result<DateTime, FormatError> bigDay = personResult.mapToResult(
  (person) => parse(person.birthDateString),
);
```

Parsing the `Person` may succeed, but parsing the `DateTime` may fail. In that case, an initial `success` is transformed into a `failure`. Aliased to `flatMap` as well for newcomers from Swift.

### mapErrorToResult

Use this to turn an error into either a success or another error. Most useful for recovering from errors which have a workaround.

Here, `mapErrorToResult` is used to ignore errors which can be resolved by a cache lookup. An initial `failure` is transformed into a `success` whenever the required value is available in the local cache. The `_getPersonCache` function also translates both unrecoverable original `DioError`s, and any internal errors accessing the cache, into the more generic `FetchError`.

```dart
final Result<Person, DioError> raw = await dioGetApiPerson(id);
final Result<Person, FetchError> output = raw.mapErrorToResult((error) => _getPersonCache(id, error));

Result<Person, FetchError> _getPersonCache(int id, DioError error) {
  // ...
}
```

Aliased to `flatMapError` for Swift newcomers.

### mapToResultWhen

Rarely used. This allows a single action to both try another operation on a success `value` which may fail in a new way with a new `error` type, and to recover from any original `error` with a `success` or translate the error into the new type of `Failure`.

```dart
Result<Person, DioError> fetchPerson(int id) {
  // ...
}
Result<String, ProcessingError> fullName = fetchPerson(12).mapToResultWhen(
    success: (person) => _fullName(person.firstName, person,lastName),
    failure: (dioError) => _asProcessingError(dioError),
);
```

Aliased to `flatMapWhen`, though Swift doesn't have this equivalent.

## Alternatives

- [Result](https://pub.dev/packages/result) matches most of Swift's `Result` type.
- [result_type](https://pub.dev/packages/result_type) which fully matches Swift, and some Rust.
- [fluent_result](https://pub.dev/packages/fluent_result) allows multiple errors in a failure, and allows custom errors by extending a `ResultError` class.
- [Dartz](https://pub.dev/packages/dartz) is a functional programming package whose `Either` type can be used as a substitute for `Result`. It has no concept of success and failure. Instead it uses `left` and `right`.
