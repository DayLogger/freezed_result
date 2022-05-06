import 'package:freezed_result/freezed_result.dart';
import 'package:test/test.dart';

void main() {
  test('Nothing is a singleton', () {
    final subject = Result.success(nothing);
    expect(identical(subject.maybeValue, nothing), true);
  });

  group('Result.success', () {
    test('isSuccess is true, and isFailure is false', () {
      final successSubject = Result<int, Error>.success(12);
      expect(successSubject.isSuccess, true);
      expect(successSubject.isFailure, false);
    });

    test('maybeValue returns the value', () {
      final successSubject = Result<int, Error>.success(12);
      expect(successSubject.maybeValue, isNotNull);
      expect(successSubject.maybeValue, 12);
    });

    test('maybeError returns null', () {
      final successSubject = Result<int, Error>.success(12);
      expect(successSubject.maybeError, isNull);
    });

    test('valueOrThrow returns the value', () {
      final successSubject = Result<int, UnimplementedError>.success(12);
      expect(successSubject.valueOrThrow(), 12);
    });
  });
  group('Result.failure', () {
    test('isSuccess is false, and isFailure is true', () {
      final failureSubject = Result<int, Error>.failure(Error());
      expect(failureSubject.isSuccess, false);
      expect(failureSubject.isFailure, true);
    });

    test('maybeValue returns null', () {
      final failureSubject = Result<int, Error>.failure(Error());
      expect(failureSubject.maybeValue, isNull);
    });

    test('maybeError returns an error', () {
      var error = Error();
      final failureSubject = Result<int, Error>.failure(error);
      expect(failureSubject.maybeError, isNotNull);
      expect(failureSubject.maybeError, error);
    });
    test('valueOrThrow throws the error', () {
      final failureSubject =
          Result<int, UnimplementedError>.failure(UnimplementedError());
      expect(() => failureSubject.valueOrThrow(),
          throwsA(isA<UnimplementedError>()));
    });
  });

  group('When closure does not throw', () {
    test('the return value is wrapped in Result.success', () {
      final subject = Result.catching(() => 12);
      expect(subject.isSuccess, true);
      expect(subject.maybeValue, isNotNull);
      expect(subject.maybeValue, 12);
      expect(subject.maybeError, isNull);
    });
  });

  group('When closure throws', () {
    test('Result.catching() returns a Result.failure<Object>', () {
      final shouldThrow = true;
      final subject = Result.catching(
        () => shouldThrow ? throw StateError('') : 12,
      );
      expect(subject, isA<Result<int, Object>>());
      expect(subject, isNot(isA<Result<int, StateError>>()));
      expect(subject.isSuccess, false);
      expect(subject.maybeValue, isNull);
      expect(subject.maybeError, isNotNull);
      expect(subject.maybeError, isA<Object>());
    });

    group('a StateError', () {
      test(
          'Result.catching<_, StateError>() returns a Result.failure<StateError>',
          () {
        final subject = Result.catching<int, StateError>(
          () => throw StateError(''),
        );
        expect(subject, isA<Result<int, StateError>>());
        expect(subject.isSuccess, false);
        expect(subject.maybeValue, isNull);
        expect(subject.maybeError, isNotNull);
        expect(subject.maybeError, isA<StateError>());
      });

      test('Result.catching<_, StateError>() lets ArgumentError go uncaught',
          () {
        expect(
          () => Result.catching<int, StateError>(() => throw ArgumentError('')),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });

  group('result.when', () {
    test('success closure called if result.isSuccess', () {
      final result = Result<int, StateError>.success(12);
      int subject = 0;
      result.when(
        success: (value) => subject = value,
        failure: (_) => subject = -1,
      );
      expect(subject, 12);
    });

    test('failure closure called if result.isFailure', () {
      final result = Result<int, StateError>.failure(StateError(''));
      int subject = 0;
      result.when(
        success: (value) => subject = value,
        failure: (_) => subject = -1,
      );
      expect(subject, -1);
    });

    test('returns the value of the success closure if result.isSuccess', () {
      final result = Result<int, StateError>.success(12);
      final subject = result.when(
        success: (value) => '$value',
        failure: (error) => '$error',
      );
      expect(subject, "12");
    });

    test('returns the value of the failure closure if result.isFailure', () {
      final result = Result<int, StateError>.failure(StateError('bad stuff'));
      final subject = result.when(
        success: (value) => '$value',
        failure: (error) => '$error',
      );
      expect(subject, "Bad state: bad stuff");
    });
  });

  group('result.map', () {
    test('transforms the success value', () {
      final subject = Result.success(12).map((value) => '$value');
      expect(subject, isA<Result<String, Object>>());
      expect(subject.maybeValue, '12');
      expect(subject.maybeError, isNull);
    });

    test('does not change the error', () {
      final Result<int, StateError> result = Result.failure(StateError(''));
      final subject = result.map((value) => '$value');
      expect(subject, isA<Result<String, StateError>>());
      expect(subject.maybeValue, isNull);
      expect(subject.maybeError, isA<StateError>());
    });
  });

  group('result.mapError', () {
    test('does not change the success value', () {
      final subject =
          Result.success(12).mapError((error) => StateError(error.toString()));
      expect(subject, isA<Result<int, Object>>());
      expect(subject.maybeValue, 12);
      expect(subject.maybeError, isNull);
    });

    test('transforms the error', () {
      final Result<int, ArgumentError> result =
          Result.failure(ArgumentError('7 is wrong'));
      final subject = result.mapError((error) => StateError(error.toString()));
      expect(subject, isA<Result<int, StateError>>());
      expect(subject.maybeValue, isNull);
      expect(subject.maybeError, isA<StateError>());
      final errorString = subject.maybeError.toString();
      expect(errorString, 'Bad state: Invalid argument(s): 7 is wrong');
    });
  });

  group('result.mapWhen', () {
    test('transforms the success value', () {
      final subject = Result.success(12).mapWhen(
        success: (value) => '$value',
        failure: (error) => StateError(error.toString()),
      );
      expect(subject, isA<Result<String, StateError>>());
      expect(subject.maybeValue, '12');
      expect(subject.maybeError, isNull);
    });

    test('transforms the error', () {
      final subject = Result.failure(ArgumentError('7 is wrong')).mapWhen(
        success: (value) => '$value',
        failure: (error) => StateError(error.toString()),
      );
      expect(subject, isA<Result<String, StateError>>());
      expect(subject.maybeValue, isNull);
      expect(subject.maybeError, isA<StateError>());
      final errorString = subject.maybeError.toString();
      expect(errorString, 'Bad state: Invalid argument(s): 7 is wrong');
    });
  });

  group('result.mapToResult', () {
    Result<String, ArgumentError> stringify(int value) => value > 5
        ? Result.success('$value')
        : Result.failure(ArgumentError('$value is bad'));

    test('can transform the success value to a Result.success', () {
      final subject = Result.success(12).mapToResult(stringify);
      expect(subject, isA<Result<String, Object>>());
      expect(subject.maybeValue, '12');
      expect(subject.maybeError, isNull);
    });

    test('can transform the success value to a Result.failure', () {
      final subject = Result.success(0).mapToResult(stringify);
      expect(subject, isA<Result<String, ArgumentError>>());
      expect(subject.maybeValue, isNull);
      expect(subject.maybeError, isA<ArgumentError>());
      expect(subject.maybeError.toString(), 'Invalid argument(s): 0 is bad');
    });

    test('does not change the error', () {
      final Result<int, ArgumentError> result =
          Result.failure(ArgumentError('whimsy'));
      final subject = result.mapToResult(stringify);
      expect(subject, isA<Result<String, ArgumentError>>());
      expect(subject.maybeValue, isNull);
      expect(subject.maybeError, isA<ArgumentError>());
      expect(subject.maybeError.toString(), 'Invalid argument(s): whimsy');
    });
  });

  group('result.mapErrorToResult', () {
    Result<int, StateError> interpret(ArgumentError error) =>
        error.toString().contains('whimsy')
            ? Result.success(0)
            : Result.failure(StateError(error.toString()));

    test('does not change the success value', () {
      final Result<int, ArgumentError> result = Result.success(12);
      final subject = result.mapErrorToResult(interpret);
      expect(subject, isA<Result<int, Object>>());
      expect(subject.maybeValue, 12);
      expect(subject.maybeError, isNull);
    });

    test('can transform the error to Result.success', () {
      final subject =
          Result.failure(ArgumentError('whimsy')).mapErrorToResult(interpret);
      expect(subject, isA<Result<int, StateError>>());
      expect(subject.maybeValue, 0);
      expect(subject.maybeError, isNull);
    });

    test('can transform the error to Result.failure', () {
      final subject = Result.failure(ArgumentError('7 is wrong'))
          .mapErrorToResult(interpret);
      expect(subject, isA<Result<int, StateError>>());
      expect(subject.maybeValue, isNull);
      expect(subject.maybeError, isA<StateError>());
      final errorString = subject.maybeError.toString();
      expect(errorString, 'Bad state: Invalid argument(s): 7 is wrong');
    });
  });

  group('result.mapToResultWhen', () {
    Result<String, StateError> stringify(int value) => value > 5
        ? Result.success('$value')
        : Result.failure(StateError('Cannot process'));

    Result<String, StateError> interpret(ArgumentError error) =>
        error.toString().contains('whimsy')
            ? Result.success('0')
            : Result.failure(StateError(error.toString()));

    test('can transform the success value to a Result.success', () {
      final Result<int, ArgumentError> result = Result.success(12);
      final subject = result.mapToResultWhen(
        success: stringify,
        failure: interpret,
      );
      expect(subject, isA<Result<String, StateError>>());
      expect(subject.maybeValue, '12');
      expect(subject.maybeError, isNull);
    });

    test('can transform the success value to a Result.failure', () {
      final Result<int, ArgumentError> result = Result.success(0);
      final subject = result.mapToResultWhen(
        success: stringify,
        failure: interpret,
      );
      expect(subject, isA<Result<String, StateError>>());
      expect(subject.maybeValue, isNull);
      expect(subject.maybeError, isA<StateError>());
      expect(subject.maybeError.toString(), 'Bad state: Cannot process');
    });

    test('can transform the error to Result.success', () {
      final Result<int, ArgumentError> result =
          Result.failure(ArgumentError('whimsy'));
      final subject = result.mapToResultWhen(
        success: stringify,
        failure: interpret,
      );
      expect(subject, isA<Result<String, StateError>>());
      expect(subject.maybeValue, '0');
      expect(subject.maybeError, isNull);
    });

    test('can transform the error to Result.failure', () {
      final Result<int, ArgumentError> result =
          Result.failure(ArgumentError('7 is wrong'));
      final subject = result.mapToResultWhen(
        success: stringify,
        failure: interpret,
      );
      expect(subject, isA<Result<String, StateError>>());
      expect(subject.maybeValue, isNull);
      expect(subject.maybeError, isA<StateError>());
      final errorString = subject.maybeError.toString();
      expect(errorString, 'Bad state: Invalid argument(s): 7 is wrong');
    });
  });
}
