import 'dart:io';
import 'package:coaching_fit_coach/core/theme/app_theme.dart';
import 'package:coaching_fit_coach/core/theme/text_styles.dart';
import 'package:coaching_fit_coach/features/certificates/presentation/cubit/certificate_cubit.dart';
import 'package:coaching_fit_coach/features/certificates/presentation/cubit/certificate_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:coaching_fit_coach/core/widgets/responsive_helper.dart';

class UploadCertificateScreen extends StatefulWidget {
  const UploadCertificateScreen({super.key});

  @override
  State<UploadCertificateScreen> createState() => _UploadCertificateScreenState();
}

class _UploadCertificateScreenState extends State<UploadCertificateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _orgController = TextEditingController();
  DateTime? _issuedDate;
  File? _pickedFile;
  String? _pickedFileName;

  @override
  void dispose() {
    _titleController.dispose();
    _orgController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
        _pickedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _issuedDate ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: AppColors.textPrimary,
            surface: AppColors.card,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _issuedDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_issuedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the issued date.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a certificate file.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<CertificateCubit>().upload(
          title: _titleController.text.trim(),
          issuingOrganization: _orgController.text.trim(),
          issuedDate: _issuedDate!,
          file: _pickedFile!,
        );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _orgController.clear();
    setState(() {
      _issuedDate = null;
      _pickedFile = null;
      _pickedFileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Add Certificate', style: AppTextStyles.heading3),
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocConsumer<CertificateCubit, CertificateState>(
          listener: (context, state) {
            if (state is CertificateUploadSuccess) {
              _showSuccessSheet(context, state);
            } else if (state is CertificateUploadError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isUploading = state is CertificateUploading;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: responsive.horizontalPadding, vertical: 16),
              child: responsive.content(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Certificate Details', style: AppTextStyles.heading3),
                      const SizedBox(height: 6),
                      Text(
                        'Fill in the details below. Admin will review and verify your credentials.',
                        style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _inputDecoration(
                          'Certificate Title',
                          'e.g. NASM Certified Personal Trainer',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Title is required.' : null,
                      ),
                      const SizedBox(height: 16),

                      // Issuing Org
                      TextFormField(
                        controller: _orgController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _inputDecoration(
                          'Issuing Organization',
                          'e.g. National Academy of Sports Medicine',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Issuing organization is required.' : null,
                      ),
                      const SizedBox(height: 16),

                      // Issued Date
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius:
                                BorderRadius.circular(responsive.cardRadius),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 18, color: AppColors.textHint),
                              const SizedBox(width: 12),
                              Text(
                                _issuedDate == null
                                    ? 'Issued Date'
                                    : DateFormat.yMMMMd().format(_issuedDate!),
                                style: TextStyle(
                                  color: _issuedDate == null
                                      ? AppColors.textHint
                                      : AppColors.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // File Picker
                      GestureDetector(
                        onTap: _pickFile,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius:
                                BorderRadius.circular(responsive.cardRadius),
                            border: Border.all(
                              color: _pickedFile != null
                                  ? AppColors.primary
                                  : AppColors.borderColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _pickedFile != null
                                    ? Icons.attach_file
                                    : Icons.upload_file_outlined,
                                color: _pickedFile != null
                                    ? AppColors.primary
                                    : AppColors.textHint,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _pickedFileName ?? 'Pick certificate file (PDF, JPG, PNG)',
                                  style: TextStyle(
                                    color: _pickedFile != null
                                        ? AppColors.textPrimary
                                        : AppColors.textHint,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_pickedFile != null)
                                GestureDetector(
                                  onTap: () => setState(() {
                                    _pickedFile = null;
                                    _pickedFileName = null;
                                  }),
                                  child: const Icon(Icons.close,
                                      size: 18, color: AppColors.textHint),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Max 10MB. Accepted: PDF, JPG, PNG, WebP',
                        style: AppTextStyles.bodyS.copyWith(color: AppColors.textHint),
                      ),
                      const SizedBox(height: 32),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        height: responsive.buttonHeight,
                        child: ElevatedButton(
                          onPressed: isUploading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(responsive.cardRadius),
                            ),
                          ),
                          child: isUploading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Text('Upload Certificate'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    final responsive = ResponsiveHelper(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: AppColors.textHint),
      hintStyle: const TextStyle(color: AppColors.textHint),
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  void _showSuccessSheet(
      BuildContext context, CertificateUploadSuccess state) {
    final responsive = ResponsiveHelper(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(responsive.cardRadius)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 52),
            const SizedBox(height: 12),
            Text('Uploaded Successfully', style: AppTextStyles.heading3),
            const SizedBox(height: 6),
            Text(
              'Admin will review "${state.certificate.title}" shortly.',
              style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _resetForm();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize:
                          Size(double.infinity, responsive.buttonHeight * 0.9),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(responsive.cardRadius)),
                    ),
                    child: Text('Add Another',
                        style: AppTextStyles.bodyM.copyWith(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          Size(double.infinity, responsive.buttonHeight * 0.9),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(responsive.cardRadius)),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
