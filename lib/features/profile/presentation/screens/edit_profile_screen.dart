import 'dart:io';

import 'package:coaching_fit_coach/core/theme/app_theme.dart';
import 'package:coaching_fit_coach/core/theme/text_styles.dart';
import 'package:coaching_fit_coach/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:coaching_fit_coach/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  int _experienceYears = 0;
  File? _profileImage;
  String _gender = '';

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileSuccess) {
      _bioController.text = profileState.profile.bio;
      _experienceYears = profileState.profile.experienceYears;
      _gender = profileState.profile.gender;
    }
  }

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: Text('Save', style: AppTextStyles.bodyL.copyWith(color: AppColors.primary)),
          )
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            context.pop(); // ViewProfileScreen.initState() will refetch
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 32),
                  _buildDisabledGender(),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 5,
                    maxLength: 1000,
                    decoration: _inputDecoration('Bio'),
                    style: AppTextStyles.bodyM,
                  ),
                  const SizedBox(height: 20),
                  _buildExperienceStepper(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: state is ProfileLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: state is ProfileLoading
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : Text('Save Changes', style: AppTextStyles.button),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar() {
    final profileState = context.read<ProfileCubit>().state;
    String? photoUrl;
    if (profileState is ProfileSuccess) {
      photoUrl = profileState.profile.profilePhotoUrl;
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.card,
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : (photoUrl != null ? NetworkImage(photoUrl) : null) as ImageProvider?,
            child: _profileImage == null && photoUrl == null
                ? const Icon(Icons.person, color: AppColors.textHint, size: 60)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledGender() {
    return Tooltip(
      message: 'Gender cannot be changed',
      child: AbsorbPointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Gender', style: AppTextStyles.bodyL),
                const SizedBox(width: 8),
                const Icon(Icons.lock, color: AppColors.textHint, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0x80162240),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Row(
                children: [
                  Text(_gender, style: AppTextStyles.bodyM.copyWith(color: AppColors.textHint)),
                ],
              ),
            ),
          ],
        ),
      ),
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

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileCubit>().updateProfile(
            bio: _bioController.text.trim(),
            experienceYears: _experienceYears,
            photo: _profileImage,
          );
    }
  }
}
