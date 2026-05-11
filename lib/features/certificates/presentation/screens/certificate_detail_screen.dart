import 'dart:io';
import 'package:coaching_fit_coach/core/theme/app_theme.dart';
import 'package:coaching_fit_coach/core/theme/text_styles.dart';
import 'package:coaching_fit_coach/features/certificates/data/models/certificate_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:coaching_fit_coach/core/widgets/responsive_helper.dart';

class CertificateDetailScreen extends StatefulWidget {
  final CertificateResponse certificate;

  const CertificateDetailScreen({super.key, required this.certificate});

  @override
  State<CertificateDetailScreen> createState() => _CertificateDetailScreenState();
}

class _CertificateDetailScreenState extends State<CertificateDetailScreen> {
  bool _pdfLoading = true;
  String? _localPdfPath;
  String? _pdfError;

  @override
  void initState() {
    super.initState();
    if (widget.certificate.fileType == 'pdf') {
      _downloadPdf();
    }
  }

  Future<void> _downloadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.certificate.fileUrl));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.certificate.fileName}');
      await file.writeAsBytes(response.bodyBytes);
      if (mounted) setState(() => _localPdfPath = file.path);
    } catch (_) {
      if (mounted) setState(() => _pdfError = 'Failed to load PDF.');
    } finally {
      if (mounted) setState(() => _pdfLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cert = widget.certificate;
    final isPdf = cert.fileType == 'pdf';
    final statusColor = _statusColor(cert.status);
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Certificate', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: responsive.content(
        child: Column(
          children: [
            // Metadata card
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: responsive.horizontalPadding, vertical: 16),
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
                        child: Text(cert.title,
                            style: AppTextStyles.bodyL
                                .copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cert.status,
                          style: AppTextStyles.bodyS.copyWith(
                              color: statusColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(cert.issuingOrganization,
                      style: AppTextStyles.bodyS.copyWith(
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  _infoRow(
                      Icons.calendar_today_outlined,
                      'Issued: ${DateFormat.yMMMMd().format(cert.issuedDate)}'),
                  if (cert.reviewedAt != null)
                    _infoRow(Icons.check_circle_outline,
                        'Reviewed: ${DateFormat.yMMMMd().format(cert.reviewedAt!)}'),
                  if (cert.status == 'Rejected' && cert.rejectionReason != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(20),
                        borderRadius: BorderRadius.circular(
                            responsive.cardRadius / 2),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline,
                              size: 14, color: AppColors.error),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(cert.rejectionReason!,
                                style: AppTextStyles.bodyS
                                    .copyWith(color: AppColors.error)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // File viewer
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding),
                child: isPdf
                    ? _buildPdfViewer()
                    : _buildImageViewer(cert.fileUrl),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    if (_pdfLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }
    if (_pdfError != null || _localPdfPath == null) {
      return Center(
        child: Text(
          _pdfError ?? 'Unable to display PDF.',
          style: AppTextStyles.bodyM.copyWith(color: AppColors.error),
        ),
      );
    }
    return PDFView(
      filePath: _localPdfPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      backgroundColor: AppColors.background,
    );
  }

  Widget _buildImageViewer(String url) {
    return InteractiveViewer(
      child: Center(
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
          errorBuilder: (_, __, ___) => Text(
            'Failed to load image.',
            style: AppTextStyles.bodyM.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textHint),
          const SizedBox(width: 6),
          Text(text,
              style: AppTextStyles.bodyS.copyWith(color: AppColors.textHint)),
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
}
