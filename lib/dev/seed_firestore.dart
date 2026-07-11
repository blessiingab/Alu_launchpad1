import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// One-time dev helper that seeds Firestore with sample data matching the
/// REAL schema the app reads (see lib/data/models/*.dart). Not called
/// anywhere automatically — trigger it manually from a dev screen/button,
/// or temporarily call `FirestoreSeeder.seed()` from main() while testing,
/// then remove the call before shipping.
///
/// You must be signed in (as a startup_admin test account) before calling
/// this, since it uses your current uid as the startup owner.
class FirestoreSeeder {
  static final _db = FirebaseFirestore.instance;

  static Future<void> seed() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Login first before seeding Firestore.');
    }

    const startupId = 'startup001';
    const opportunityId = 'opportunity001';

    //-------------------------------------------------
    // USERS  (top-level `users` collection, doc id == auth uid)
    // Matches AppUser.fromMap in lib/data/models/app_user.dart
    //-------------------------------------------------
    await _db.collection('users').doc(user.uid).set({
      'name': 'Faith',
      'email': user.email,
      'role': 'startup_admin', // 'student' | 'startup_admin'
      'skills': ['Flutter', 'Firebase', 'Business'],
      'startupIds': [startupId],
      'bookmarks': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });

    //-------------------------------------------------
    // STARTUPS  (top-level `startups` collection)
    // Matches Startup.fromMap in lib/data/models/startup.dart
    //-------------------------------------------------
    await _db.collection('startups').doc(startupId).set({
      'name': 'AgriTech',
      'description': 'Technology for farmers.',
      'logoUrl': null,
      'category': 'Agriculture',
      'verificationStatus': 'verified', // 'pending' | 'verified' | 'rejected'
      'verificationNote': 'ALU Innovation Club',
      'adminUids': [user.uid],
      'createdAt': FieldValue.serverTimestamp(),
    });

    //-------------------------------------------------
    // OPPORTUNITIES  (top-level `opportunities` collection)
    // Matches Opportunity.fromMap in lib/data/models/opportunity.dart
    //-------------------------------------------------
    await _db.collection('opportunities').doc(opportunityId).set({
      'startupId': startupId,
      'startupName': 'AgriTech',
      'title': 'Flutter Developer Intern',
      'description': 'Build our mobile application.',
      'type': 'internship', // 'internship' | 'job' | 'volunteer' | 'project'
      'skillsRequired': ['Flutter', 'Firebase'],
      'location': 'Kigali',
      'isRemote': true,
      'status': 'open', // 'open' | 'closed'
      'deadline': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 30)),
      ),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}