import 'failure.dart';

/// A value that is either a [Success] or an [ResultError] — the only
/// two shapes a repository call can return. Consume with a `switch`
/// expression so the compiler forces both branches to be handled:
///
/// ```dart
/// final result = await repository.getProgramas();
/// switch (result) {
///   case Success(:final value) => showList(value),
///   case ResultError(:final failure) => showError(failure.message),
/// }
/// ```
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class ResultError<T> extends Result<T> {
  const ResultError(this.failure);

  final Failure failure;
}

extension ResultX<T> on Result<T> {
  bool get isSuccess => this is Success<T>;

  T? get valueOrNull => switch (this) {
    Success<T>(:final value) => value,
    ResultError<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    ResultError<T>(:final failure) => failure,
  };

  R fold<R>(
    R Function(T value) onSuccess,
    R Function(Failure failure) onError,
  ) => switch (this) {
    Success<T>(:final value) => onSuccess(value),
    ResultError<T>(:final failure) => onError(failure),
  };
}
