import 'package:flutter/material.dart';
import 'package:online_thekedaar/models/user_profile.dart';
import 'package:online_thekedaar/services/user_repository.dart';
import 'package:animate_do/animate_do.dart';
import 'package:online_thekedaar/config/app_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userRepo = UserRepository();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _userRepo.getUserProfile();
    if (profile != null) {
      _nameController.text = profile.name;
      _phoneController.text = profile.phone;
      _addressController.text = profile.address;
      _emailController.text = profile.email;
    }
    setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final profile = UserProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      email: _emailController.text,
    );
    
    await _userRepo.saveUserProfile(profile);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully!'))
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  FadeInDown(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppConfig.primaryColor.withOpacity(0.2),
                      child: const Icon(Icons.person, size: 50, color: AppConfig.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildField('Full Name', _nameController, Icons.person_outline),
                  const SizedBox(height: 20),
                  _buildField('Phone Number', _phoneController, Icons.phone_android_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  _buildField('Email Address', _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  _buildField('Home Address', _addressController, Icons.home_outlined, maxLines: 3),
                  const SizedBox(height: 40),
                  FadeInUp(
                    child: FilledButton(
                      onPressed: _saveProfile,
                      child: const Text('Save Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}
