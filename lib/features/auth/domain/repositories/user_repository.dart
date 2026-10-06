import 'package:showscape/features/auth/domain/models/app_user.dart';
import 'package:showscape/features/auth/domain/models/auth_result.dart';

abstract class UserRepository {
  /// Fetch current user profile
  Future<AppUser?> getCurrentUser();

  /// Update user profile
  Future<AppUser> updateProfile(AppUser user);

  /// Toggle gold membership status
  Future<AppUser> toggleGoldMembership();

  /// Sign in with email and password. Demo account: prity@showscape.ai / showscape
  Future<AuthResult> signIn({
    required String email,
    required String password,
  });

  /// Create an account and make it the current user.
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required List<String> preferredCities,
    required List<String> favoriteGenres,
    required List<String> favoriteLanguages,
  });
}
