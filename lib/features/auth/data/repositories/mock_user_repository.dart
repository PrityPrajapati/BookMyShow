import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:showscape/features/auth/domain/models/app_user.dart';
import 'package:showscape/features/auth/domain/models/auth_result.dart';
import 'package:showscape/features/auth/domain/repositories/user_repository.dart';

class _AccountRecord {
  _AccountRecord({required this.user, required this.password});

  AppUser user;
  final String password;
}

class MockUserRepository implements UserRepository {
  static const String demoPassword = 'showscape';

  AppUser? _cachedUser;
  final Map<String, _AccountRecord> _accounts = <String, _AccountRecord>{};
  bool _seeded = false;

  Future<void> _ensureSeeded() async {
    if (_seeded) return;

    final jsonStr = await rootBundle.loadString('assets/mock/users.json');
    final decoded = jsonDecode(jsonStr);
    if (decoded is! List || decoded.isEmpty) {
      _seeded = true;
      return;
    }
    final first = decoded.first;
    if (first is! Map) {
      _seeded = true;
      return;
    }
    final user = AppUser.fromJson(Map<String, dynamic>.from(first));
    _accounts[user.email.toLowerCase()] = _AccountRecord(
      user: user,
      password: demoPassword,
    );
    _cachedUser = user;
    _seeded = true;
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _ensureSeeded();
    return _cachedUser;
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _ensureSeeded();
    _cachedUser = user;
    final existing = _accounts[user.email.toLowerCase()];
    if (existing != null) {
      existing.user = user;
    }
    return user;
  }

  @override
  Future<AppUser> toggleGoldMembership() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final current = await _loadCurrent();
    final updated = current.copyWith(
      isGoldMember: !current.isGoldMember,
      goldExpiry: !current.isGoldMember
          ? DateTime.now().add(const Duration(days: 365))
          : null,
    );
    _cachedUser = updated;
    final existing = _accounts[updated.email.toLowerCase()];
    if (existing != null) existing.user = updated;
    return updated;
  }

  Future<AppUser> _loadCurrent() async {
    await _ensureSeeded();
    final current = _cachedUser;
    if (current == null) {
      throw StateError('No signed-in user');
    }
    return current;
  }

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    await _ensureSeeded();
    final record = _accounts[email.trim().toLowerCase()];
    if (record == null || record.password != password) {
      return const AuthResult.failure('Email or password is incorrect.');
    }
    _cachedUser = record.user;
    return AuthResult.success(record.user);
  }

  @override
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required List<String> preferredCities,
    required List<String> favoriteGenres,
    required List<String> favoriteLanguages,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    await _ensureSeeded();
    final normalizedEmail = email.trim().toLowerCase();
    if (_accounts.containsKey(normalizedEmail)) {
      return const AuthResult.failure('An account with this email already exists.');
    }
    final user = AppUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      isGoldMember: false,
      preferredCities: preferredCities,
      favoriteGenres: favoriteGenres,
      favoriteLanguages: favoriteLanguages,
      createdAt: DateTime.now(),
    );
    _accounts[normalizedEmail] = _AccountRecord(user: user, password: password);
    _cachedUser = user;
    return AuthResult.success(user);
  }
}
