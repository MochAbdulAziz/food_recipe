import 'package:bloc/bloc.dart';
import '../../data/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  /// Call once on startup — reads persisted user from SharedPreferences.
  void checkAuth() {
    final user = _authService.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signInWithEmail(email, password);
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Sign in failed. Please try again.'));
    }
  }

  Future<void> signUpWithEmail(
      String email, String password, String displayName) async {
    emit(AuthLoading());
    try {
      final user =
          await _authService.signUpWithEmail(email, password, displayName);
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Registration failed. Please try again.'));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await _authService.signInWithGoogle();
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Google sign-in failed. Please try again.'));
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      await _authService.updateProfile(
          displayName: displayName, photoUrl: photoUrl);
      final user = _authService.currentUser;
      if (user != null) emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    }
  }
}
