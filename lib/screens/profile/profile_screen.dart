import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_healthcare_system/providers/auth_provider.dart';
import 'package:smart_healthcare_system/utils/app_theme.dart';
import 'package:smart_healthcare_system/widgets/custom_button.dart';
import 'package:smart_healthcare_system/widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await Provider.of<AuthProvider>(context, listen: false).updateProfile(
        name: _nameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign out')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: AppTextStyles.heading1.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Personal Information',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icons.person_outline,
                readOnly: !_isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                readOnly: true, // Email cannot be changed
              ),
              const SizedBox(height: 32),
              const Text(
                'App Settings',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              _buildSettingTile(
                'Notifications',
                'Manage notification preferences',
                Icons.notifications_outlined,
                onTap: () {
                  // Navigate to notifications settings
                },
              ),
              _buildSettingTile(
                'Privacy',
                'Manage your data and privacy settings',
                Icons.security_outlined,
                onTap: () {
                  // Navigate to privacy settings
                },
              ),
              _buildSettingTile(
                'Help & Support',
                'Get help and contact support',
                Icons.help_outline,
                onTap: () {
                  // Navigate to help & support
                },
              ),
              _buildSettingTile(
                'About',
                'App version and information',
                Icons.info_outline,
                onTap: () {
                  // Navigate to about screen
                },
              ),
              const SizedBox(height: 32),
              if (_isEditing) ...[
                CustomButton(
                  text: 'Save Changes',
                  onPressed: _updateProfile,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Cancel',
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _nameController.text = user?.name ?? '';
                    });
                  },
                  isOutlined: true,
                ),
              ] else ...[
                CustomButton(
                  text: 'Sign Out',
                  onPressed: _signOut,
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
