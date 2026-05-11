import 'package:coaching_fit_coach/core/theme/app_theme.dart';
import 'package:coaching_fit_coach/core/theme/text_styles.dart';
import 'package:coaching_fit_coach/core/widgets/responsive_helper.dart';
import 'package:coaching_fit_coach/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
          child: responsive.content(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderColor, width: 2),
                  ),
                  child: Icon(Icons.hourglass_top_rounded,
                      color: AppColors.primary, size: responsive.screenWidth * 0.2),
                ),
                const SizedBox(height: 32),
                Text('Profile Under Review', textAlign: TextAlign.center, style: AppTextStyles.heading2),
                const SizedBox(height: 16),
                Text(
                  'Your profile has been submitted for review. This process usually takes 24-48 hours. We will notify you once it is approved.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyM
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 48),
                _buildStatusTracker(context),
                const SizedBox(height: 20),
                _buildCertificatesAction(context),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () => context.go('/view-profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: Size(double.infinity, responsive.buttonHeight),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(responsive.cardRadius)),
                  ),
                  child: Text('Check My Status', style: AppTextStyles.button),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    await context.read<AuthCubit>().logout();
                    if (context.mounted) context.go('/login');
                  },
                  child: Text(
                    'Log Out',
                    style: AppTextStyles.bodyM.copyWith(color: AppColors.error),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCertificatesAction(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        border: Border.all(color: AppColors.primary.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_outlined,
              color: AppColors.primary, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upload Certificates',
                    style: AppTextStyles.bodyL
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  'Speed up your approval by uploading your credentials.',
                  style: AppTextStyles.bodyS
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => context.push('/certificates'),
            child: Text('Add',
                style: AppTextStyles.bodyM
                    .copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTracker(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: const Column(
        children: [
          StatusStep(title: 'Account Created', isDone: true),
          StatusStep(title: 'Profile Submitted', isDone: true),
          StatusStep(title: 'Under Review', isActive: true),
          StatusStep(title: 'Ready to Coach', isLocked: true),
        ],
      ),
    );
  }
}

class StatusStep extends StatefulWidget {
  final String title;
  final bool isDone;
  final bool isActive;
  final bool isLocked;

  const StatusStep({
    super.key,
    required this.title,
    this.isDone = false,
    this.isActive = false,
    this.isLocked = false,
  });

  @override
  State<StatusStep> createState() => _StatusStepState();
}

class _StatusStepState extends State<StatusStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          if (widget.isActive)
            FadeTransition(
              opacity: _controller,
              child: _buildIcon(),
            )
          else
            _buildIcon(),
          const SizedBox(width: 16),
          Text(
            widget.title,
            style: AppTextStyles.bodyL.copyWith(
              color: widget.isLocked ? AppColors.textHint : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color color;
    if (widget.isDone) {
      iconData = Icons.check_circle;
      color = AppColors.success;
    } else if (widget.isActive) {
      iconData = Icons.hourglass_bottom_rounded;
      color = AppColors.primary;
    } else if (widget.isLocked) {
      iconData = Icons.lock;
      color = AppColors.textHint;
    } else {
      iconData = Icons.circle_outlined;
      color = AppColors.textHint;
    }
    return Icon(iconData, color: color, size: 28);
  }
}
