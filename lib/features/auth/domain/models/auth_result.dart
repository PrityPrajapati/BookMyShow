import 'package:showscape/features/auth/domain/models/app_user.dart';

class AuthResult {
  const AuthResult.success(this.user) : errorMessage = null;

  const AuthResult.failure(this.errorMessage) : user = null;

  final AppUser? user;
  final String? errorMessage;

  bool get isSuccess => user != null;
}
