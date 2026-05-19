import 'package:coaching_fit_coach/core/widgets/responsive_helper.dart';
import 'package:coaching_fit_coach/core/theme/app_theme.dart';
import 'package:coaching_fit_coach/core/theme/text_styles.dart';
import 'package:coaching_fit_coach/features/certificates/domain/entities/certificate.dart';
import 'package:coaching_fit_coach/features/certificates/presentation/cubit/certificate_cubit.dart';
import 'package:coaching_fit_coach/features/certificates/presentation/cubit/certificate_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coaching_fit_coach/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MyCertificatesScreen extends StatefulWidget {
  const MyCertificatesScreen({super.key});

  @override
  State<MyCertificatesScreen> createState() => _MyCertificatesScreenState();
}

class _MyCertificatesScreenState extends State<MyCertificatesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CertificateCubit>().loadCertificates();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Certificates', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRoutes.certificatesUpload),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Certificate', style: AppTextStyles.bodyS.copyWith(color: Colors.white)),
      ),
      body: BlocConsumer<CertificateCubit, CertificateState>(
        listener: (context, state) {
          if (state is CertificateDeleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Certificate deleted.')),
            );
            context.read<CertificateCubit>().loadCertificates();
          } else if (state is CertificateDeleteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CertificateLoading || state is CertificateDeleting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is CertificateError) {
            return Center(
              child: Text(
                state.message,
                style: AppTextStyles.bodyM.copyWith(color: AppColors.error),
              ),
            );
          }

          if (state is CertificateLoaded) {
            if (state.certificates.isEmpty) {
              return _buildEmptyState(responsive);
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  context.read<CertificateCubit>().loadCertificates(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final padding = EdgeInsets.fromLTRB(
                      responsive.horizontalPadding, 16,
                      responsive.horizontalPadding, 100);
                  if (ResponsiveHelper.isWide(constraints)) {
                    return GridView.builder(
                      padding: padding,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 480,
                        mainAxisExtent: 230,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: state.certificates.length,
                      itemBuilder: (context, index) => _buildCertCard(
                          context, state.certificates[index], responsive),
                    );
                  }
                  return ListView.separated(
                    padding: padding,
                    itemCount: state.certificates.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildCertCard(
                        context, state.certificates[index], responsive),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(ResponsiveHelper responsive) {
    return Center(
      child: responsive.content(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.workspace_premium_outlined,
                  size: 72, color: AppColors.textHint),
              const SizedBox(height: 20),
              Text('No Certificates Yet', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Text(
                'Upload your certifications so the admin can review and verify your credentials.',
                style:
                    AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: responsive.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: () => context.pushNamed(AppRoutes.certificatesUpload),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Your First Certificate'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(responsive.cardRadius),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertCard(BuildContext context, Certificate cert,
      ResponsiveHelper responsive) {
    final statusColor = _statusColor(cert.status);
    final statusIcon = _statusIcon(cert.status);
    final canDelete = cert.status != 'Approved';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(cert.title, style: AppTextStyles.bodyL.copyWith(fontWeight: FontWeight.bold)),
              ),
              if (canDelete)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _confirmDelete(context, cert),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(cert.issuingOrganization,
              style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                DateFormat.yMMMMd().format(cert.issuedDate),
                style: AppTextStyles.bodyS.copyWith(color: AppColors.textHint),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      cert.status,
                      style: AppTextStyles.bodyS.copyWith(
                          color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (cert.status == 'Rejected' && cert.rejectionReason != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                borderRadius: BorderRadius.circular(responsive.cardRadius / 2),
                border: Border.all(color: AppColors.error.withAlpha(60)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 14, color: AppColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      cert.rejectionReason!,
                      style: AppTextStyles.bodyS.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => context.pushNamed(
              AppRoutes.certificateDetail,
              pathParameters: {'id': cert.id},
              extra: cert,
            ),
            child: Row(
              children: [
                Icon(
                  cert.fileType == 'pdf'
                      ? Icons.picture_as_pdf_outlined
                      : Icons.image_outlined,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  cert.fileName,
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.primary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Certificate cert) {
    final responsive = ResponsiveHelper(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.cardRadius)),
        title: Text('Delete Certificate', style: AppTextStyles.heading3),
        content: Text(
          'Delete "${cert.title}"? This action cannot be undone.',
          style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CertificateCubit>().delete(cert.id);
            },
            child: Text('Delete', style: AppTextStyles.bodyM.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'Approved' => AppColors.success,
      'Rejected' => AppColors.error,
      _ => AppColors.warning,
    };
  }

  IconData _statusIcon(String status) {
    return switch (status) {
      'Approved' => Icons.check_circle_outline,
      'Rejected' => Icons.cancel_outlined,
      _ => Icons.hourglass_empty_outlined,
    };
  }
}
