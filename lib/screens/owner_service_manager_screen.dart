import 'package:day35/config/app_config.dart';
import 'package:day35/services/app_settings_repository.dart';
import 'package:day35/services/service_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OwnerServiceManagerScreen extends StatefulWidget {
  const OwnerServiceManagerScreen({super.key});

  @override
  State<OwnerServiceManagerScreen> createState() =>
      _OwnerServiceManagerScreenState();
}

class _OwnerServiceManagerScreenState extends State<OwnerServiceManagerScreen> {
  final ServiceRepository _repository = ServiceRepository();
  final AppSettingsRepository _settingsRepository = AppSettingsRepository();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();

  List<String> _services = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Owner Service Manager'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF101820),
        elevation: 0,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'WhatsApp receiving number',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bookings and status requests are routed to this number. Use country code without +.',
                    style: TextStyle(color: Colors.grey.shade700, height: 1.35),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _whatsappController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Admin WhatsApp Number',
                      hintText: '918878976452',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _saveWhatsappNumber,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Save number'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.outlined(
                        tooltip: 'Reset number',
                        onPressed: _resetWhatsappNumber,
                        icon: const Icon(Icons.restart_alt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Customer-facing services',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add services here and the customer home screen will use this list.',
                    style: TextStyle(color: Colors.grey.shade700, height: 1.35),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _serviceController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'New service name',
                            hintText: 'Example: 🧹 Deep Cleaning',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onSubmitted: (_) => _addService(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          onPressed: _addService,
                          child: const Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_services.isEmpty)
                    const Center(child: Text('No services added yet.')),
                  for (final service in _services)
                    Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(
                          service,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        trailing: IconButton(
                          tooltip: 'Delete service',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteService(service),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _resetServices,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset default services'),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _loadServices() async {
    final results = await Future.wait([
      _repository.loadServices(),
      _settingsRepository.loadWhatsappNumber(),
    ]);
    if (!mounted) return;
    setState(() {
      _services = results[0] as List<String>;
      _whatsappController.text = results[1] as String;
      _loading = false;
    });
  }

  Future<void> _addService() async {
    final service = _serviceController.text.trim();
    if (service.isEmpty) return;
    if (_services.contains(service)) {
      _showMessage('This service already exists.');
      return;
    }

    final updatedServices = [..._services, service];
    await _repository.saveServices(updatedServices);
    if (!mounted) return;
    setState(() {
      _services = updatedServices;
      _serviceController.clear();
    });
    _showMessage('Service added.');
  }

  Future<void> _deleteService(String service) async {
    final updatedServices = _services.where((item) => item != service).toList();
    await _repository.saveServices(updatedServices);
    if (!mounted) return;
    setState(() => _services = updatedServices);
    _showMessage('Service removed.');
  }

  Future<void> _resetServices() async {
    await _repository.resetServices();
    await _loadServices();
    _showMessage('Default services restored.');
  }

  Future<void> _saveWhatsappNumber() async {
    final cleanNumber =
        _whatsappController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.length < 10) {
      _showMessage('Enter a valid WhatsApp number with country code.');
      return;
    }

    await _settingsRepository.saveWhatsappNumber(cleanNumber);
    if (!mounted) return;
    setState(() => _whatsappController.text = cleanNumber);
    _showMessage('WhatsApp number saved.');
  }

  Future<void> _resetWhatsappNumber() async {
    await _settingsRepository.resetWhatsappNumber();
    if (!mounted) return;
    setState(() {
      _whatsappController.text = AppConfig.defaultWhatsappBusinessNumber;
    });
    _showMessage('WhatsApp number reset to app default.');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
