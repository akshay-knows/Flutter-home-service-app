import 'package:day35/config/app_config.dart';
import 'package:day35/screens/booking_form_screen.dart';
import 'package:day35/screens/owner_service_manager_screen.dart';
import 'package:day35/screens/status_update_screen.dart';
import 'package:day35/services/service_repository.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ServiceRepository _repository = ServiceRepository();

  List<String> _services = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF101820),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Owner services',
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: _openOwnerManager,
          ),
          IconButton(
            tooltip: 'Status update',
            icon: const Icon(Icons.manage_search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatusUpdateScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadServices,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Book trusted local service workers',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101820),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppConfig.tagline}. Choose a service and send your booking directly to Online Thekedaar on WhatsApp.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_services.isEmpty)
                const Center(child: Text('No services available right now.'))
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _services.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.25,
                  ),
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return _ServiceTile(
                      title: service,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                BookingFormScreen(serviceName: service),
                          ),
                        );
                      },
                    );
                  },
                ),
              const SizedBox(height: 22),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const StatusUpdateScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text('Ask for booking status'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadServices() async {
    final services = await _repository.loadServices();
    if (!mounted) return;
    setState(() {
      _services = services;
      _loading = false;
    });
  }

  Future<void> _openOwnerManager() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OwnerServiceManagerScreen()),
    );
    await _loadServices();
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101820),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
