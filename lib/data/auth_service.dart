import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── User model ────────────────────────────────────────────────────────────────

class UserModel extends Equatable {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;

  const UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  UserModel copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
  }) =>
      UserModel(
        id: id,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        email: json['email'] as String,
        photoUrl: json['photoUrl'] as String?,
      );

  @override
  List<Object?> get props => [id, displayName, email, photoUrl];
}

// ── Abstract contract ────────────────────────────────────────────────────────

abstract class AuthService {
  /// Emits the current user whenever the auth state changes.
  Stream<UserModel?> get authStateChanges;

  /// Synchronously available after [init].
  UserModel? get currentUser;

  Future<void> init();
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(
      String email, String password, String displayName);

  /// Mock Google sign-in; real implementation would use google_sign_in.
  Future<UserModel> signInWithGoogle();

  Future<void> signOut();
  Future<void> updateProfile({String? displayName, String? photoUrl});
}

// ── Mock implementation (SharedPreferences-backed) ───────────────────────────

class MockAuthService implements AuthService {
  static const _userKey = 'mock_auth_user';

  UserModel? _currentUser;
  final _authController = StreamController<UserModel?>.broadcast();

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Stream<UserModel?> get authStateChanges => _authController.stream;

  @override
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw != null) {
      _currentUser = UserModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    }
    _authController.add(_currentUser);
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    if (email.trim().isEmpty || password.length < 6) {
      throw const AuthException('Invalid email or password.');
    }
    final user = UserModel(
      id: 'local_${email.hashCode.abs()}',
      displayName: email.split('@').first,
      email: email.trim(),
    );
    await _persist(user);
    return user;
  }

  @override
  Future<UserModel> signUpWithEmail(
      String email, String password, String displayName) async {
    if (email.trim().isEmpty) throw const AuthException('Email is required.');
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters.');
    }
    if (displayName.trim().isEmpty) {
      throw const AuthException('Name is required.');
    }
    final user = UserModel(
      id: 'local_${email.hashCode.abs()}',
      displayName: displayName.trim(),
      email: email.trim(),
    );
    await _persist(user);
    return user;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    const user = UserModel(
      id: 'google_demo_001',
      displayName: 'Demo Chef',
      email: 'demo@foodapp.com',
      photoUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=60',
    );
    await _persist(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    _currentUser = null;
    _authController.add(null);
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    if (_currentUser == null) throw const AuthException('Not authenticated.');
    final updated = _currentUser!.copyWith(
      displayName: displayName,
      photoUrl: photoUrl,
    );
    await _persist(updated);
  }

  Future<void> _persist(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    _currentUser = user;
    _authController.add(user);
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
