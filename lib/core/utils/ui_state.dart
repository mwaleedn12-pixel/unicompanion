sealed class UiState<T> {
  const UiState._();

  const factory UiState.initial() = UiInitial<T>;
  const factory UiState.loading() = UiLoading<T>;
  const factory UiState.success(T data) = UiSuccess<T>;
  const factory UiState.error(String message) = UiError<T>;

  bool get isLoading => this is UiLoading<T>;
  bool get isSuccess => this is UiSuccess<T>;

  T? get dataOrNull => isSuccess ? (this as UiSuccess<T>).data : null;

  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String message) error,
  }) {
    return switch (this) {
      UiInitial<T>() => initial(),
      UiLoading<T>() => loading(),
      UiSuccess<T>(data: final d) => success(d),
      UiError<T>(message: final m) => error(m),
    };
  }
}

final class UiInitial<T> extends UiState<T> {
  const UiInitial() : super._();
}

final class UiLoading<T> extends UiState<T> {
  const UiLoading() : super._();
}

final class UiSuccess<T> extends UiState<T> {
  final T data;
  const UiSuccess(this.data) : super._();
}

final class UiError<T> extends UiState<T> {
  final String message;
  const UiError(this.message) : super._();
}