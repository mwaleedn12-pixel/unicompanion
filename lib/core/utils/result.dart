sealed class Result<T> {
  const Result._();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(String message) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;

  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) {
    return switch (this) {
      Success<T>(data: final d) => success(d),
      Failure<T>(message: final m) => failure(m),
    };
  }
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data) : super._();
}

final class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message) : super._();
}