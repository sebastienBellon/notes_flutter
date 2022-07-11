import '../../models/models.dart';
import '../repositories.dart';

abstract class BaseAuthRepository extends BaseRepository {
  Future<User> loginAnonymously();
  Future<User> signupWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<User> loginWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<User> logout();
  Future<User?> getCurrentUser();
  Future<bool> isAnonymous();
}
