import 'package:online_thekedaar/models/user_profile.dart';
import 'package:online_thekedaar/services/tracking_number_service.dart';
import 'package:online_thekedaar/services/user_repository.dart';
import 'package:online_thekedaar/services/whatsapp_service.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:online_thekedaar/config/app_config.dart';
import 'package:geolocator/geolocator.dart';

class BookingFormScreen extends StatefulWidget {
  final String serviceName;
  const BookingFormScreen({super.key, required this.serviceName});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userRepo = UserRepository();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;
  String? _locationUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _determinePosition();
  }

  Future<void> _loadUserProfile() async {
    final profile = await _userRepo.getUserProfile();
    if (profile != null) {
      setState(() {
        _nameController.text = profile.name;
        _phoneController.text = profile.phone;
        _addressController.text = profile.address;
      });
    }
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _locationUrl = 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.serviceName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField('Full Name', _nameController, Icons.person_outline),
              const SizedBox(height: 20),
              _buildField('Phone Number', _phoneController, Icons.phone_android_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              _buildField('Service Address', _addressController, Icons.location_on_outlined, maxLines: 3),
              const SizedBox(height: 20),
              _buildField('Notes', _notesController, Icons.note_add_outlined, required: false),
              const SizedBox(height: 32),
              if (_locationUrl != null) 
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Row(children: [Icon(Icons.location_on, color: Colors.green), SizedBox(width: 8), Text('GPS Location Captured')]),
                ),
              const SizedBox(height: 40),
              FilledButton(
                onPressed: _isSubmitting ? null : _submitBooking,
                child: _isSubmitting ? const CircularProgressIndicator() : const Text('Send Booking via WhatsApp'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text, int maxLines = 1, bool required = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          validator: (value) => (required && (value == null || value.isEmpty)) ? 'Required' : null,
        ),
      ],
    );
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final trackingId = TrackingNumberService.generate();
    await TrackingNumberService.saveLastTrackingId(trackingId); // Save for persistence

    final message = '''
*NEW BOOKING REQUEST*
*Service:* ${widget.serviceName}
*ID:* $trackingId

*Customer:* ${_nameController.text}
*Phone:* ${_phoneController.text}
*Address:* ${_addressController.text}
${_locationUrl != null ? '*Location:* $_locationUrl' : ''}
''';

    await WhatsappService.sendToBusiness(message);
    setState(() => _isSubmitting = false);
    Navigator.pop(context);
  }
}
