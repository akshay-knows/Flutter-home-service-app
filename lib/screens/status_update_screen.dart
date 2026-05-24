import 'package:day35/services/whatsapp_service.dart';
import 'package:flutter/material.dart';

class StatusUpdateScreen extends StatefulWidget {
  const StatusUpdateScreen({super.key});

  @override
  State<StatusUpdateScreen> createState() => _StatusUpdateScreenState();
}

class _StatusUpdateScreenState extends State<StatusUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _trackingController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Booking Status'),
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
                'Ask for an update',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your tracking number and send a pre-filled WhatsApp message.',
                style: TextStyle(color: Colors.grey.shade700, height: 1.35),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _trackingController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Tracking Number',
                  hintText: 'OT-123456',
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tracking number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _submitting ? null : _requestUpdate,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(
                    _submitting ? 'Opening WhatsApp...' : 'Request Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final launched = await WhatsappService.requestStatusUpdate(
      _trackingController.text.trim().toUpperCase(),
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          launched
              ? 'Status request opened in WhatsApp.'
              : 'WhatsApp could not be opened on this device.',
        ),
      ),
    );
  }
}
