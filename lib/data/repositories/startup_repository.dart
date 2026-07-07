import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/startup.dart';

/// Wraps the `startups` Firestore collection.
///
/// Verification is intentionally *not* self-service: a startup_admin can
/// create a startup profile, but it always starts at `pending` and only
/// flips to `verified` via a platform-admin action (Firestore Console for
/// this project, or a future admin screen). Opportunity posting is gated
/// on `verified` status, both in the UI and — critically — in Firestore
/// security rules, so this can't be bypassed client-side.
class StartupRepository {
  StartupRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _startupsCol =>
      _firestore.collection('startups');

  Stream<Startup?> startupStream(String startupId) {
    return _startupsCol.doc(startupId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return Startup.fromMap(snap.id, snap.data()!);
    });
  }

  Future<Startup?> fetchStartup(String startupId) async {
    final snap = await _startupsCol.doc(startupId).get();
    if (!snap.exists || snap.data() == null) return null;
    return Startup.fromMap(snap.id, snap.data()!);
  }

  /// Creates a new startup profile owned by [adminUid], status = pending.
  /// Returns the new startup's document id.
  Future<String> createStartup({
    required String name,
    required String description,
    required String category,
    required String verificationNote,
    required String adminUid,
  }) async {
    final startup = Startup(
      id: '', // Firestore will assign
      name: name,
      description: description,
      category: category,
      verificationStatus: VerificationStatus.pending,
      verificationNote: verificationNote,
      adminUids: [adminUid],
    );

    final docRef = await _startupsCol.add(startup.toMap());
    return docRef.id;
  }

  Future<void> updateProfile({
    required String startupId,
    String? name,
    String? description,
    String? category,
  }) {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (category != null) updates['category'] = category;
    if (updates.isEmpty) return Future.value();
    return _startupsCol.doc(startupId).update(updates);
  }

  /// Platform-admin only in production (enforced via security rules).
  /// Exposed here so a future admin screen can call it directly.
  Future<void> setVerificationStatus(
    String startupId,
    VerificationStatus status,
  ) {
    return _startupsCol.doc(startupId).update({
      'verificationStatus': verificationStatusToString(status),
    });
  }
}
