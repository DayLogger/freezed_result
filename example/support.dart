import 'package:freezed_result/freezed_result.dart';

class DatabaseError {
  final String message;
  DatabaseError(this.message);

  @override
  String toString() => message;
}

class User {
  final int id;
  User(this.id);
}

class DioError {
  final String message;
  DioError(this.message);

  @override
  String toString() => message;
}

// DON'T do this -- pretend this is a Freezed Union
class AuthFailure {
  const AuthFailure._(this.message);
  final String message;
  factory AuthFailure.network(DioError error) =>
      AuthFailure._('Network error: $error');
  factory AuthFailure.storage(DatabaseError error) =>
      AuthFailure._('Database error: $error');
  factory AuthFailure.validation(String message) =>
      AuthFailure._('Validation error: $message');

  @override
  String toString() => message;
}

// DON'T do this -- pretend this is a Freezed Union
class AuthState {
  const AuthState._(this.message);
  final String message;
  factory AuthState.authenticated(User user) =>
      AuthState._('Authenticated user ${user.id}.');
  factory AuthState.error(AuthFailure error) =>
      AuthState._('Authentication error: $error');
  factory AuthState.unauthenticated() => AuthState._('Bad user or password.');
  @override
  String toString() => message;
}

class FakeDio {
  Future<int?> get(int id) async {
    return Future.delayed(
      Duration(seconds: 1),
      () {
        if (_shouldThrow(id)) {
          throw DioError('Socket timeout');
        } else if (_isNotFound(id)) {
          return null;
        } else {
          return id;
        }
      },
    );
  }

  static bool _shouldThrow(int id) => id == 1;

  static bool _isNotFound(int id) => id == 2;
}

class Database {
  Future<void> save(User? user) async {
    if (user?.id == 3) {
      throw DatabaseError('Cannot save user 3.');
    }
    return;
  }
}
