import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_thekedaar/config/app_config.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of services from Firestore
  Stream<List<String>> getServices() {
    return _firestore.collection('services').orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  // Add service (Admin only)
  Future<void> addService(String name) async {
    await _firestore.collection('services').add({'name': name});
  }

  // Delete service (Admin only)
  Future<void> deleteService(String name) async {
    final snapshot = await _firestore.collection('services').where('name', isEqualTo: name).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Update Settings (Admin only)
  Future<void> updateWhatsapp(String number) async {
    await _firestore.collection('settings').doc('admin').set({'whatsapp': number}, SetOptions(merge: true));
  }

  // Stream of Admin WhatsApp number
  Stream<String> getWhatsappNumber() {
    return _firestore.collection('settings').doc('admin').snapshots().map((doc) {
      if (doc.exists && doc.data()!.containsKey('whatsapp')) {
        return doc.get('whatsapp') as String;
      }
      return AppConfig.whatsappNumber;
    });
  }
}
