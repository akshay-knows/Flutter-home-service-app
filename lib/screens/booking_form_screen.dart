import 'package:day35/models/booking_request.dart';
import 'package:day35/services/tracking_number_service.dart';
import 'package:day35/services/whatsapp_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({
    super.key,
    required this.serviceName,
  });

  final String serviceName;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _manualAddressController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _requiredDateTime;
  Position? _position;
  bool _fetchingLocation = false;
  bool _submitting = false;
  String? _locationMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _whatsappController.dispose();
    _manualAddressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(widget.serviceName),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF101820),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Booking Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              _TextField(
                controller: _nameController,
                label: 'Customer Name',
                textInputAction: TextInputAction.next,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              _TextField(
                controller: _whatsappController,
                label: 'WhatsApp Number',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'WhatsApp number is required';
                  if (text.length < 10) return 'Enter a valid WhatsApp number';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _LocationPanel(
                fetching: _fetchingLocation,
                position: _position,
                message: _locationMessage,
                onFetch: _fetchLocation,
              ),
              const SizedBox(height: 14),
              _TextField(
                controller: _manualAddressController,
                label: 'Manual Address',
                maxLines: 3,
                textInputAction: TextInputAction.newline,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              _DateTimeField(
                value: _requiredDateTime,
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 14),
              _TextField(
                controller: _descriptionController,
                label: 'What needs to be done',
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_submitting
                    ? 'Opening WhatsApp...'
                    : 'Send Booking on WhatsApp'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _fetchingLocation = true;
      _locationMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setLocationFallback(
          'Location service is off. You can continue with manual address.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _setLocationFallback(
          'Location permission denied. You can continue with manual address.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() {
        _position = position;
        _locationMessage = 'Location fetched successfully.';
      });
    } catch (_) {
      _setLocationFallback(
        'Could not fetch location. You can continue with manual address.',
      );
    } finally {
      if (mounted) {
        setState(() => _fetchingLocation = false);
      }
    }
  }

  void _setLocationFallback(String message) {
    if (!mounted) return;
    setState(() {
      _position = null;
      _locationMessage = message;
    });
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      initialDate: _requiredDateTime ?? now,
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_requiredDateTime ?? now),
    );
    if (time == null) return;

    setState(() {
      _requiredDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_requiredDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select required date and time.')),
      );
      return;
    }

    setState(() => _submitting = true);

    final booking = BookingRequest(
      trackingNumber: TrackingNumberService.generate(),
      serviceName: widget.serviceName,
      customerName: _nameController.text.trim(),
      customerWhatsapp: _whatsappController.text.trim(),
      manualAddress: _manualAddressController.text.trim(),
      requiredDateTime: _requiredDateTime!,
      jobDescription: _descriptionController.text.trim(),
      latitude: _position?.latitude,
      longitude: _position?.longitude,
    );

    final launched = await WhatsappService.sendToBusiness(
      booking.toWhatsappMessage(),
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          launched
              ? 'Booking ${booking.trackingNumber} opened in WhatsApp.'
              : 'WhatsApp could not be opened on this device.',
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.validator,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class _LocationPanel extends StatelessWidget {
  const _LocationPanel({
    required this.fetching,
    required this.position,
    required this.message,
    required this.onFetch,
  });

  final bool fetching;
  final Position? position;
  final String? message;
  final VoidCallback onFetch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Auto-Fetched Location',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: fetching ? null : onFetch,
                icon: fetching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(fetching ? 'Fetching' : 'Fetch GPS'),
              ),
            ],
          ),
          if (position != null)
            Text(
              '${position!.latitude}, ${position!.longitude}',
              style: TextStyle(color: Colors.green.shade800),
            ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.value,
    required this.onTap,
  });

  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'When required',
          filled: true,
          fillColor: Colors.white,
          suffixIcon: Icon(Icons.calendar_month),
        ),
        child: Text(
          value == null ? 'Select date and time' : _formatDateTime(value!),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day-$month-$year $hour:$minute';
  }
}
