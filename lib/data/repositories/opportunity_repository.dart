import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/opportunity.dart';

/// Wraps the `opportunities` Firestore collection.
///
/// Queries deliberately avoid combining a `where` filter with an
/// `orderBy` on a different field (that requires a manually-created
/// Firestore composite index) — instead each stream sorts client-side
/// after the snapshot comes in. Fine at this app's scale, and it means
/// nothing extra has to be configured in the Firebase console.
class OpportunityRepository {
  OpportunityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('opportunities');

  /// All open opportunities, newest first. Powers the student feed.
  Stream<List<Opportunity>> openOpportunitiesStream() {
    return _col.where('status', isEqualTo: 'open').snapshots().map((snap) {
      final items = snap.docs
          .map((d) => Opportunity.fromMap(d.id, d.data()))
          .toList();
      items.sort((a, b) => (b.createdAt ?? DateTime(0))
          .compareTo(a.createdAt ?? DateTime(0)));
      return items;
    });
  }

  /// Every opportunity posted by one startup (open + closed), newest
  /// first. Powers the startup's own "manage opportunities" list.
  Stream<List<Opportunity>> byStartupStream(String startupId) {
    return _col.where('startupId', isEqualTo: startupId).snapshots().map((snap) {
      final items = snap.docs
          .map((d) => Opportunity.fromMap(d.id, d.data()))
          .toList();
      items.sort((a, b) => (b.createdAt ?? DateTime(0))
          .compareTo(a.createdAt ?? DateTime(0)));
      return items;
    });
  }

  /// Same as [byStartupStream] but across every startup an admin owns —
  /// `whereIn` supports up to 30 ids, far more than any admin here will
  /// realistically have. Empty list short-circuits to an empty stream
  /// rather than sending an invalid empty `whereIn`.
  Stream<List<Opportunity>> byStartupIdsStream(List<String> startupIds) {
    if (startupIds.isEmpty) return Stream.value(const []);
    return _col
        .where('startupId', whereIn: startupIds)
        .snapshots()
        .map((snap) {
      final items = snap.docs
          .map((d) => Opportunity.fromMap(d.id, d.data()))
          .toList();
      items.sort((a, b) => (b.createdAt ?? DateTime(0))
          .compareTo(a.createdAt ?? DateTime(0)));
      return items;
    });
  }

  Stream<Opportunity?> byIdStream(String id) {
    return _col.doc(id).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return Opportunity.fromMap(snap.id, snap.data()!);
    });
  }

  Future<Opportunity?> fetch(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists || snap.data() == null) return null;
    return Opportunity.fromMap(snap.id, snap.data()!);
  }

  Future<String> create(Opportunity opportunity) async {
    final docRef = await _col.add(opportunity.toMap());
    return docRef.id;
  }

  Future<void> update(String id, Map<String, dynamic> updates) {
    return _col.doc(id).update(updates);
  }

  Future<void> setStatus(String id, OpportunityStatus status) {
    return _col.doc(id).update({'status': opportunityStatusToString(status)});
  }

  Future<void> delete(String id) {
    return _col.doc(id).delete();
  }
}