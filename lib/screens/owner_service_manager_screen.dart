import 'package:online_thekedaar/services/sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class OwnerServiceManagerScreen extends StatefulWidget {
  const OwnerServiceManagerScreen({super.key});

  @override
  State<OwnerServiceManagerScreen> createState() =>
      _OwnerServiceManagerScreenState();
}

class _OwnerServiceManagerScreenState extends State<OwnerServiceManagerScreen> {
  final SyncService _syncService = SyncService();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedIcon;

  @override
  void dispose() {
    _serviceController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedIcon = File(image.path));
      _showMessage('Icon selected (Local preview). Setup Firebase Storage for full sync!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Console')),
      body: StreamBuilder<String>(
        stream: _syncService.getWhatsappNumber(),
        builder: (context, whatsappSnapshot) {
          if (whatsappSnapshot.hasData && _whatsappController.text.isEmpty) {
            _whatsappController.text = whatsappSnapshot.data!;
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              FadeInDown(
                child: _buildSectionHeader('Branding', 'Customize your app look.'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        image: _selectedIcon != null ? DecorationImage(image: FileImage(_selectedIcon!), fit: BoxFit.cover) : null,
                      ),
                      child: _selectedIcon == null ? const Icon(Icons.add_a_photo_outlined) : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(child: Text('Tap to change App Icon or Theme Image')),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('WhatsApp Number', 'Syncs to all customers instantly.'),
              const SizedBox(height: 16),
              TextField(
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Business Number',
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.cloud_upload_rounded, color: Colors.blue),
                    onPressed: () => _syncService.updateWhatsapp(_whatsappController.text),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Manage Services', 'Add services in real-time.'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _serviceController,
                      decoration: const InputDecoration(labelText: 'New Service', hintText: '🧹 Cleaning'),
                      onSubmitted: (_) => _addService(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: _addService,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              StreamBuilder<List<String>>(
                stream: _syncService.getServices(),
                builder: (context, snapshot) {
                  final services = snapshot.data ?? [];
                  return Column(
                    children: [
                      for (var service in services)
                        Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(service),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _syncService.deleteService(service),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
      ],
    );
  }

  Future<void> _addService() async {
    final name = _serviceController.text.trim();
    if (name.isNotEmpty) {
      await _syncService.addService(name);
      _serviceController.clear();
      _showMessage('Service Added to Cloud');
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }
}
