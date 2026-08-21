import '../../../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<Result<UserEntity>> signInWithEmail(String email, String password) async {
    try {
      final response = await _datasource.signInWithEmail(email, password);
      if (response.user == null) return Result.failure('Login failed');
      return Result.success(_mapUser(response.user!));
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<UserEntity>> signUpWithEmail(String email, String password, String fullName) async {
    try {
      final response = await _datasource.signUpWithEmail(email, password, fullName);
      if (response.user == null) return Result.failure('Registration failed');
      return Result.success(_mapUser(response.user!));
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<UserEntity>> signInWithGoogle() async {
    try {
      final response = await _datasource.signInWithGoogle();
      if (response.user == null) return Result.failure('Google sign-in failed');
      return Result.success(_mapUser(response.user!));
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    try {
      await _datasource.resetPassword(email);
      return Result.success(null);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _datasource.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.failure(_handleError(e));
    }
  }

  @override
  UserEntity? get currentUser {
    final user = _datasource.currentUser;
    if (user == null) return null;
    return _mapUser(user);
  }

  UserEntity _mapUser(dynamic user) {
    return UserEntity(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'],
      avatarUrl: user.userMetadata?['avatar_url'],
    );
  }

  String _handleError(dynamic e) {
    if (e.toString().contains('Invalid login credentials')) {
      return 'Email or password is incorrect';
    }
    if (e.toString().contains('User already registered')) {
      return 'An account with this email already exists';
    }
    if (e.toString().contains('Email not confirmed')) {
      return 'Please verify your email first';
    }
    if (e.toString().contains('cancelled')) {
      return 'Sign-in was cancelled';
    }
    return 'Something went wrong. Please try again.';
  }
}