part of 'result.dart';

class _SuccessResult<Success, Failure extends Object>
    extends Result<Success, Failure> {
  const _SuccessResult(this.value) : super._();

  final Success value;

  @override
  String toString() {
    return 'Result<$Success, $Failure>.success(value: $value)';
  }

  @override
  bool get isSuccess => true;

  @override
  Success? get maybeValue => value;

  @override
  Failure? get maybeError => null;

  @override
  Success valueOrThrow() => value;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SuccessResult<Success, Failure> &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(value));

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Success value) success,
    required TResult Function(Failure error) failure,
  }) {
    return success(value);
  }
}
