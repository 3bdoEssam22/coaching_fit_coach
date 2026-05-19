import 'package:coaching_fit_coach/core/routing/app_routes.dart';
import 'package:coaching_fit_coach/core/widgets/responsive_helper.dart';
import 'package:coaching_fit_coach/core/theme/app_theme.dart';
import 'package:coaching_fit_coach/core/theme/text_styles.dart';
import 'package:coaching_fit_coach/features/profile/domain/entities/coach_profile.dart';
import 'package:coaching_fit_coach/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:coaching_fit_coach/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:coaching_fit_coach/features/auth/presentation/cubit/auth_cubit.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().getMyProfile();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Profile', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () => context.pushNamed(AppRoutes.editProfile),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)));
          } else if (state is ProfileSuccess) {
            final profile = state.profile;
            final fullName = state.fullName;
            final isActive = state.isActive;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
              child: responsive.content(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    if (!isActive) _buildPendingBanner(responsive),
                    _buildHeroCard(profile, fullName, responsive),
                    const SizedBox(height: 24),
                    _buildAboutCard(profile.bio, responsive),
                    const SizedBox(height: 24),
                    _buildDetailsCard(profile, responsive),
                    const SizedBox(height: 24),
                    _buildCertificatesCard(context, responsive),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          } else if (state is ProfileFailure) {
            return Center(child: Text(state.message, style: AppTextStyles.bodyL.copyWith(color: AppColors.error)));
          }
          return const Center(child: Text('No profile data'));
        },
      ),
      bottomNavigationBar: null,
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Log Out', style: AppTextStyles.heading3),
        content: Text(
          'You\'ll need to sign in again to access your account.',
          style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Log Out', style: AppTextStyles.bodyM.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthCubit>().logout();
      if (context.mounted) context.go('/login');
    }
  }

  Widget _buildPendingBanner(ResponsiveHelper responsive) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0x33FFC107),
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        border: Border.all(color: Colors.amber),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your profile is pending approval. Some features may be limited.',
              style: AppTextStyles.bodyS.copyWith(color: Colors.amber.shade200),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(CoachProfile profile, String fullName, ResponsiveHelper responsive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: responsive.avatarRadius,
            backgroundColor: AppColors.primary,
            backgroundImage: profile.profilePhotoUrl != null
                ? NetworkImage(profile.profilePhotoUrl!)
                : null,
            child: profile.profilePhotoUrl == null
                ? Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : 'C',
                    style: AppTextStyles.heading1.copyWith(
                        color: Colors.white,
                        fontSize: responsive.avatarRadius * 0.8),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(fullName, style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Chip(
            label: Text('Coach', style: AppTextStyles.bodyS.copyWith(color: AppColors.primary)),
            backgroundColor: const Color(0x191A73E8),
            side: BorderSide.none,
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.borderColor),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Rating', '4.9 ★'),
              _buildStat('Experience', '${profile.experienceYears} Yrs'),
              _buildStat('Clients', '120+'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.bodyL.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildAboutCard(String bio, ResponsiveHelper responsive) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          Text(bio, style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(CoachProfile profile, ResponsiveHelper responsive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          _buildDetailRow('Gender', profile.gender),
          _buildDetailRow('Experience', '${profile.experienceYears} years'),
          _buildDetailRow('Member Since', DateFormat.yMMMMd().format(profile.createdAt)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCertificatesCard(BuildContext context, ResponsiveHelper responsive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_outlined,
              color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Certificates', style: AppTextStyles.heading3),
                const SizedBox(height: 2),
                Text(
                  'Manage your credentials and certifications.',
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios,
                color: AppColors.primary, size: 16),
            onPressed: () => context.pushNamed(AppRoutes.certificates),
          ),
        ],
      ),
    );
  }
}
