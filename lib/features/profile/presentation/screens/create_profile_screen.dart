// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:coaching_fit_coach/core/storage/secure_storage.dart';
import 'package:coaching_fit_coach/core/theme/app_theme.dart';
import 'package:coaching_fit_coach/core/theme/text_styles.dart';
import 'package:coaching_fit_coach/features/profile/data/models/create_coach_profile_request.dart';
import 'package:coaching_fit_coach/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:coaching_fit_coach/features/profile/presentation/cubit/profile_state.dart';
import 'package:coaching_fit_coach/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

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
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileCreated) {
              sl<SecureStorage>().writeHasProfile(true).then((_) {
                if (mounted) context.go('/pending-approval');
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
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Set Up Your Profile', style: AppTextStyles.heading2),
                            const SizedBox(height: 32),
                            Center(
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: AppColors.card,
                                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                                  child: _profileImage == null
                                      ? const Icon(Icons.camera_alt, color: AppColors.textHint, size: 40)
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildGenderToggle(),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _bioController,
                              maxLines: 5,
                              maxLength: 1000,
                              decoration: _inputDecoration('Bio'),
                              validator: (value) => (value?.isEmpty ?? true) ? 'Please enter your bio' : null,
                              style: AppTextStyles.bodyM,
                            ),
                            const SizedBox(height: 20),
                            _buildExperienceStepper(),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: state is ProfileLoading ? null : _createProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size(double.infinity, 52),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: state is ProfileLoading
                                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                                  : Text('Create Profile', style: AppTextStyles.button),
                            ),
                          ],
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

  Widget _buildGenderToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: AppTextStyles.bodyL),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _genderButton('Male')),
            const SizedBox(width: 16),
            Expanded(child: _genderButton('Female')),
          ],
        ),
      ],
    );
  }

  Widget _genderButton(String gender) {
    final isSelected = _gender == gender;
    return ElevatedButton(
      onPressed: () => setState(() => _gender = gender),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary : AppColors.card,
        side: isSelected ? null : const BorderSide(color: AppColors.borderColor),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(gender, style: AppTextStyles.bodyM.copyWith(color: isSelected ? Colors.white : AppColors.textPrimary)),
    );
  }

  Widget _buildExperienceStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Experience (Years)', style: AppTextStyles.bodyL),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.bodyM.copyWith(color: AppColors.textHint),
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary)),
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
