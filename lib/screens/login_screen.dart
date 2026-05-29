import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth/auth_cubit.dart';
import '../bloc/auth/auth_state.dart';
import '../utils/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<AuthCubit>();
    if (_isSignUp) {
      cubit.signUpWithEmail(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
        _nameCtrl.text.trim(),
      );
    } else {
      cubit.signInWithEmail(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
    }
  }

  void _signInWithGoogle() => context.read<AuthCubit>().signInWithGoogle();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.accentSalmon,
            ),
          );
        }
        // Navigation on success is handled by the root MaterialApp in main.dart
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // ── Logo / Headline ──────────────────────────────────────
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.restaurant_menu_rounded,
                        color: Colors.white, size: 38),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    _isSignUp ? 'Create Account' : 'Welcome Back',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    _isSignUp
                        ? 'Sign up to save your favourite recipes'
                        : 'Sign in to continue cooking',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textMid,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // ── Form ─────────────────────────────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_isSignUp)
                        _buildField(
                          controller: _nameCtrl,
                          label: 'Full Name',
                          hint: 'Jane Cooper',
                          icon: Icons.person_outline_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Name is required'
                              : null,
                        ),
                      if (_isSignUp) const SizedBox(height: 16),
                      _buildField(
                        controller: _emailCtrl,
                        label: 'Email',
                        hint: 'you@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!v.contains('@') || !v.contains('.')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _passwordCtrl,
                        label: 'Password',
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textLight,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Minimum 6 characters'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Primary CTA ──────────────────────────────────────────
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isSignUp ? 'Create Account' : 'Sign In',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    );
                  },
                ),

                // ── Divider ──────────────────────────────────────────────
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFDDD8D3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFDDD8D3))),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Google Sign-in ───────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: const Icon(Icons.g_mobiledata_rounded,
                        size: 26, color: AppColors.textDark),
                    label: Text(
                      'Continue with Google',
                      style: GoogleFonts.poppins(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDDD8D3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Toggle sign-in / sign-up ─────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _isSignUp = !_isSignUp);
                      _formKey.currentState?.reset();
                    },
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.textMid),
                        children: [
                          TextSpan(
                            text: _isSignUp
                                ? 'Already have an account? '
                                : "Don't have an account? ",
                          ),
                          TextSpan(
                            text: _isSignUp ? 'Sign In' : 'Sign Up',
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
                fontSize: 14, color: AppColors.textLight),
            prefixIcon: Icon(icon, color: AppColors.textLight, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDD8D3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDD8D3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.accentSalmon, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.accentSalmon, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
