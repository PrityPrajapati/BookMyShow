import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication State model
class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? displayName;

  const AuthState({
    required this.isAuthenticated,
    this.userId,
    this.email,
    this.displayName,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? email,
    String? displayName,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }
}

/// Authentication Notifier with Listenable support for GoRouter refresh
class AuthNotifier extends ChangeNotifier {
  AuthState _state = const AuthState(
    isAuthenticated: true, // Default to authenticated for instant preview; toggleable in UI
    userId: 'usr_001',
    email: 'prity@showscape.ai',
    displayName: 'Prity Prajapati',
  );

  AuthState get state => _state;
  bool get isAuthenticated => _state.isAuthenticated;

  void login({
    String email = 'prity@showscape.ai',
    String displayName = 'Prity Prajapati',
    String userId = 'usr_001',
  }) {
    _state = AuthState(
      isAuthenticated: true,
      userId: userId,
      email: email,
      displayName: displayName,
    );
    notifyListeners();
  }

  void logout() {
    _state = const AuthState(
      isAuthenticated: false,
      userId: null,
      email: null,
      displayName: null,
    );
    notifyListeners();
  }

  void toggleAuth() {
    if (_state.isAuthenticated) {
      logout();
    } else {
      login();
    }
  }
}

/// Provider for Authentication Controller
final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier();
});
