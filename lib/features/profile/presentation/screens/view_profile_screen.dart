import 'package:coaching_fit_coach/core/theme/app_theme.dart';
import 'package:coaching_fit_coach/core/theme/text_styles.dart';
import 'package:coaching_fit_coach/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:coaching_fit_coach/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Profile', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () => context.go('/edit-profile'),
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)));
          } else if (state is ProfileSuccess) {
            final profile = state.profile;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // if (!profile.isActive) _buildPendingBanner(),
                  _buildHeroCard(profile),
                  const SizedBox(height: 24),
                  _buildAboutCard(profile.bio),
                  const SizedBox(height: 24),
                  _buildDetailsCard(profile),
                ],
              ),
            );
          } else if (state is ProfileFailure) {
            return Center(child: Text(state.error, style: AppTextStyles.bodyL.copyWith(color: AppColors.error)));
          }
          return const Center(child: Text('No profile data'));
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildPendingBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildHeroCard(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary,
            backgroundImage: profile.profilePhotoUrl != null ? NetworkImage(profile.profilePhotoUrl!) : null,
            child: profile.profilePhotoUrl == null
                ? Text('AB', style: AppTextStyles.heading1.copyWith(color: Colors.white)) // Placeholder
                : null,
          ),
          const SizedBox(height: 16),
          Text("Abdulrhman Mostafa", style: AppTextStyles.heading2), // Placeholder
          const SizedBox(height: 8),
          Chip(
            label: Text('Coach', style: AppTextStyles.bodyS.copyWith(color: AppColors.primary)),
            backgroundColor: AppColors.primary.withOpacity(0.1),
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

  Widget _buildAboutCard(String bio) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildDetailsCard(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      currentIndex: 1, // Profile is active
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
      ],
    );
  }
}
