import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> signInWithEmail(String email, String password);
  Future<Result<UserEntity>> signUpWithEmail(String email, String password, String fullName);
  Future<Result<UserEntity>> signInWithGoogle();
  Future<Result<void>> resetPassword(String email);
  Future<Result<void>> signOut();
  UserEntity? get currentUser;
}