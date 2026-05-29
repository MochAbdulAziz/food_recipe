import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth/auth_cubit.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/meal_plan/meal_plan_cubit.dart';
import '../data/cooking_history.dart';
import '../widgets/app_remote_image.dart';
import '../utils/colors.dart';
import 'meal_plan_screen.dart';

class ProfileScreen extends StatelessWidget {
  final int favouriteCount;
  const ProfileScreen({super.key, this.favouriteCount = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.only(
                  top: 60, left: 20, right: 20, bottom: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.textDark, Color(0xFF4A3B30)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  // Top row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderButton(Icons.arrow_back_ios_new, () {}),
                      Text(
                        'Profile',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      _buildHeaderButton(Icons.shopping_bag_outlined, () {}),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Avatar + name
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, authState) {
                      final user = authState is AuthAuthenticated ? authState.user : null;
                      final name = user?.displayName ?? 'Guest Chef';
                      final email = user?.email ?? '';
                      final photoUrl = user?.photoUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=500&auto=format&fit=crop&q=60';
                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.secondary,
                            child: ClipOval(
                              child: AppRemoteImage(
                                imageUrl: photoUrl,
                                width: 80,
                                height: 80,
                                fallback: const Icon(
                                  Icons.person_rounded,
                                  color: AppColors.textMid,
                                  size: 34,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          if (email.isNotEmpty)
                            Text(
                              email,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 22),

                  // Stats row
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _buildStat('47', 'Recipes'),
                        _buildStatDivider(),
                        _buildStat('$favouriteCount', 'Saved'),
                        _buildStatDivider(),
                        _buildStat('${CookingHistory.getCookedCount()}', 'Cooked'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Menu ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACCOUNT',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline_rounded,
                    label: 'Edit Profile',
                    desc: 'Update your info',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    desc: 'Alerts & updates',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.favorite_border_rounded,
                    label: 'Favourite Recipes',
                    desc: '$favouriteCount saved recipes',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.calendar_month_outlined,
                    label: 'Meal Planner',
                    desc: 'Plan your weekly meals',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<MealPlanCubit>(),
                          child: const MealPlanScreen(),
                        ),
                      ),
                    ),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.headset_mic_outlined,
                    label: 'Help & Support',
                    desc: 'FAQ & contact',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    desc: 'App preferences',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),

                  // Logout
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return GestureDetector(
                        onTap: () => context.read<AuthCubit>().signOut(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1EB),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE5D9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.logout_rounded,
                                    color: AppColors.accentSalmon, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'Log out',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentSalmon,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white60,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String desc,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.bgMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    desc,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textLight, size: 18),
          ],
        ),
      ),
    );
  }
}
