part of 'result.dart';

class _FailureResult<Success, Failure extends Object>
    extends Result<Success, Failure> {
  const _FailureResult(this.error) : super._();

  final Failure error;

  @override
  String toString() {
    return 'Result<$Success, $Failure>.failure(error: $error)';
  }

  @override
  bool get isSuccess => false;

  @override
  Success? get maybeValue => null;

  @override
  Failure? get maybeError => error;

  @override
  Success valueOrThrow() => throw error;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FailureResult<Success, Failure> &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(error));

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Success value) success,
    required TResult Function(Failure error) failure,
  }) {
    return failure(error);
  }
}
