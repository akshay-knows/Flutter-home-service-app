import 'package:online_thekedaar/services/tracking_number_service.dart';
import 'package:online_thekedaar/services/whatsapp_service.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:online_thekedaar/config/app_config.dart';

class StatusUpdateScreen extends StatefulWidget {
  const StatusUpdateScreen({super.key});

  @override
  State<StatusUpdateScreen> createState() => _StatusUpdateScreenState();
}

class _StatusUpdateScreenState extends State<StatusUpdateScreen> {
  final _controller = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fillLastId();
  }

  Future<void> _fillLastId() async {
    final id = await TrackingNumberService.getLastTrackingId();
    if (id != null) {
      setState(() => _controller.text = id);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Status')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            FadeInDown(child: const Icon(Icons.manage_search_rounded, size: 80, color: AppConfig.primaryColor)),
            const SizedBox(height: 24),
            const Text('Check Your Status', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Request status update on WhatsApp using your ID.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 40),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Tracking ID', prefixIcon: Icon(Icons.receipt_long_rounded)),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSending ? null : _requestUpdate,
              child: _isSending ? const CircularProgressIndicator() : const Text('Ask on WhatsApp'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestUpdate() async {
    final id = _controller.text.trim();
    if (id.isEmpty) return;
    setState(() => _isSending = true);
    await WhatsappService.requestStatusUpdate(id);
    setState(() => _isSending = false);
  }
}
