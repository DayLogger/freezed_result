import 'package:freezed_result/freezed_result.dart';

import 'support.dart';

// Main Idea
// 1. Setup a local database
// 2. Call an API for a user to login
// 3. Store user data in the database
// 4. Store access token in secure storage
void main() async {
  final databaseResult = createDatabase();

  if (databaseResult.isFailure) {
    print('Error setting up the database: ${databaseResult.maybeError}');
    return;
  }

  // Authentication error: Validation error: Password too short.
  await authenticate(0, 'b');

  // Authentication error: Network error: Socket timeout
  await authenticate(1, 'password');

  // Bad user or password.
  await authenticate(2, 'password');

  // Authentication error: Database error: Cannot save user 3.
  await authenticate(3, 'password');

  // Authenticated user 4.
  await authenticate(4, 'password');
}

Future<void> authenticate(int id, String password) async {
  var result = await apiSignIn(id, password);
  if (result.isSuccess) {
    result = await saveUserData(result.maybeValue);
  }
  final authState = result.when(
    success: (user) => (user == null)
        ? AuthState.unauthenticated()
        : AuthState.authenticated(user),
    failure: (error) => AuthState.error(error),
  );
  print(authState.toString());
  print('');
}

Result<Nothing, DatabaseError> createDatabase() {
  // Use `nothing` instead of `void` (which wouldn't work)
  return Result.success(nothing);
}

Future<Result<User?, AuthFailure>> saveUserData(User? user) async {
  // Style 1: use standard try/catch directly return success/failure
  try {
    // User 3: not saved
    await Database().save(user); // Future<void>
    return Result.success(user);
  } on DatabaseError catch (e) {
    return Result.failure(AuthFailure.storage(e));
  }
}

Future<Result<User?, AuthFailure>> apiSignIn(int id, String password) async {
  if (password.length < 2) {
    // User 0: too short
    return Result.failure(AuthFailure.validation('Password too short.'));
  }

  // Style 2: use catching, then translate value & error for return type
  final apiResult = await Result.catching<int?, DioError>(
    // User 1: socket timeout
    // User 2: user not found
    () => FakeDio().get(id), // Future<int?>
  );
  return apiResult.mapWhen(
    success: (id) => id != null ? User(id) : null,
    failure: (error) => AuthFailure.network(error),
  );
}
