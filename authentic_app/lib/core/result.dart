/// A tiny generic Result type built on a Dart 3 sealed class.
///
/// Advanced Dart: generics, sealed classes, exhaustive `switch` pattern
/// matching, and `Future` extension methods.
sealed class Result<T> {
  const Result();

  /// Runs [body] and captures any thrown error as an [Err].
  static Future<Result<V>> guard<V>(Future<V> Function() body) async {
    try {
      return Ok(await body());
    } catch (e, st) {
      return Err(e, st);
    }
  }

  R fold<R>({
    required R Function(T value) ok,
    required R Function(Object error) err,
  }) =>
      switch (this) {
        Ok(:final value) => ok(value),
        Err(:final error) => err(error),
      };

  T? get valueOrNull => switch (this) {
        Ok(:final value) => value,
        Err() => null,
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.error, [this.stackTrace]);
  final Object error;
  final StackTrace? stackTrace;
}
