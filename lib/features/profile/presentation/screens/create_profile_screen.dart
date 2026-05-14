// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:coaching_fit_coach/core/routing/app_routes.dart';
import 'package:coaching_fit_coach/core/storage/secure_storage.dart';
import 'package:coaching_fit_coach/core/theme/app_theme.dart';
import 'package:coaching_fit_coach/core/theme/text_styles.dart';
import 'package:coaching_fit_coach/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:coaching_fit_coach/features/profile/data/models/create_coach_profile_request.dart';
import 'package:coaching_fit_coach/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:coaching_fit_coach/features/profile/presentation/cubit/profile_state.dart';
import 'package:coaching_fit_coach/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:coaching_fit_coach/core/widgets/responsive_helper.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  int _experienceYears = 0;
  String? _gender;
  File? _profileImage;

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileCreated) {
              sl<SecureStorage>().writeHasProfile(true).then((_) {
                if (mounted) context.goNamed(AppRoutes.pendingApproval);
              });
            } else if (state is ProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  const LinearProgressIndicator(value: 0.5, backgroundColor: AppColors.card, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: responsive.horizontalPadding),
                      child: responsive.content(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 16),
                              Text('Set Up Your Profile',
                                  style: AppTextStyles.heading2),
                              const SizedBox(height: 32),
                              Center(
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: CircleAvatar(
                                    radius: responsive.avatarRadius,
                                    backgroundColor: AppColors.card,
                                    backgroundImage: _profileImage != null
                                        ? FileImage(_profileImage!)
                                        : null,
                                    child: _profileImage == null
                                        ? Icon(Icons.camera_alt,
                                            color: AppColors.textHint,
                                            size: responsive.avatarRadius * 0.6)
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildGenderToggle(responsive),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _bioController,
                                maxLines: 5,
                                maxLength: 1000,
                                decoration: _inputDecoration('Bio', responsive),
                                validator: (value) => (value?.isEmpty ?? true)
                                    ? 'Please enter your bio'
                                    : null,
                                style: AppTextStyles.bodyM,
                              ),
                              const SizedBox(height: 20),
                              _buildExperienceStepper(responsive),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                onPressed:
                                    state is ProfileLoading ? null : _createProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  minimumSize: Size(
                                      double.infinity, responsive.buttonHeight),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          responsive.cardRadius)),
                                ),
                                child: state is ProfileLoading
                                    ? const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white))
                                    : Text('Create Profile',
                                        style: AppTextStyles.button),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () async {
                                  await context.read<AuthCubit>().logout();
                                  if (context.mounted) context.goNamed(AppRoutes.login);
                                },
                                child: Text(
                                  'Log Out',
                                  style: AppTextStyles.bodyM
                                      .copyWith(color: AppColors.error),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGenderToggle(ResponsiveHelper responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: AppTextStyles.bodyL),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _genderButton('Male', responsive)),
            const SizedBox(width: 16),
            Expanded(child: _genderButton('Female', responsive)),
          ],
        ),
      ],
    );
  }

  Widget _genderButton(String gender, ResponsiveHelper responsive) {
    final isSelected = _gender == gender;
    return ElevatedButton(
      onPressed: () => setState(() => _gender = gender),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary : AppColors.card,
        side: isSelected ? null : const BorderSide(color: AppColors.borderColor),
        minimumSize: Size(double.infinity, responsive.buttonHeight),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.cardRadius)),
      ),
      child: Text(gender,
          style: AppTextStyles.bodyM
              .copyWith(color: isSelected ? Colors.white : AppColors.textPrimary)),
    );
  }

  Widget _buildExperienceStepper(ResponsiveHelper responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Experience (Years)', style: AppTextStyles.bodyL),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(responsive.cardRadius),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: AppColors.primary),
                onPressed: () => setState(() => _experienceYears = (_experienceYears > 0) ? _experienceYears - 1 : 0),
              ),
              Text('$_experienceYears', style: AppTextStyles.heading3),
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.primary),
                onPressed: () => setState(() => _experienceYears = (_experienceYears < 50) ? _experienceYears + 1 : 50),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, ResponsiveHelper responsive) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.bodyM.copyWith(color: AppColors.textHint),
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.cardRadius),
          borderSide: const BorderSide(color: AppColors.borderColor)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.cardRadius),
          borderSide: const BorderSide(color: AppColors.primary)),
      counterStyle: AppTextStyles.bodyS.copyWith(color: AppColors.textHint),
    );
  }

  void _createProfile() {
    if (_formKey.currentState!.validate() && _gender != null) {
      final request = CreateCoachProfileRequest(
        gender: _gender!,
        bio: _bioController.text.trim(),
        experienceYears: _experienceYears,
      );
      context.read<ProfileCubit>().createProfile(request, photo: _profileImage);
    } else if (_gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your gender'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
