import 'package:animate_do/animate_do.dart';
import 'package:online_thekedaar/config/app_config.dart';
import 'package:online_thekedaar/screens/booking_form_screen.dart';
import 'package:online_thekedaar/screens/profile_screen.dart';
import 'package:online_thekedaar/screens/status_update_screen.dart';
import 'package:online_thekedaar/services/sync_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final bool isAdmin;
  const HomeScreen({super.key, this.isAdmin = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SyncService _syncService = SyncService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Hero(
            tag: 'app_logo',
            child: Image.asset(AppConfig.logoAssetPath,
                errorBuilder: (_, __, ___) => const Icon(Icons.handyman)),
          ),
        ),
        title: const Text(AppConfig.appName),
        actions: [
          IconButton(
            tooltip: 'My Profile',
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<String>>(
          stream: _syncService.getServices(),
          builder: (context, snapshot) {
            final services = snapshot.data ?? [];
            final loading = snapshot.connectionState == ConnectionState.waiting;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How can we help\nyou today?',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppConfig.secondaryColor,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Book trusted experts for your home needs.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                if (loading)
                  const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator()))
                else if (services.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text('No services found. Admin is updating soon!'),
                      ],
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: services.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: Duration(milliseconds: 100 * index),
                        child: _ServiceTile(
                          title: service,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BookingFormScreen(serviceName: service),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 40),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 400),
                  child: _TrackBookingCard(),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TrackBookingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConfig.secondaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Track Your Booking',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Check status on WhatsApp', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
              ],
            ),
          ),
          IconButton.filled(
            style: IconButton.styleFrom(backgroundColor: AppConfig.primaryColor, padding: const EdgeInsets.all(12)),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StatusUpdateScreen())),
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppConfig.secondaryColor, size: 20),
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final parts = title.split(' ');
    final hasEmoji = parts.isNotEmpty && parts[0].length <= 2;
    final emoji = hasEmoji ? parts[0] : '🛠️';
    final name = hasEmoji ? parts.sublist(1).join(' ') : title;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppConfig.primaryColor.withOpacity(0.15), shape: BoxShape.circle),
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppConfig.secondaryColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
