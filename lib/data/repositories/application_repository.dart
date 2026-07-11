import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/application.dart';

/// Matches the `applications` collection rules:
/// - create: signed-in student, studentId == request.auth.uid
/// - read/update: the applicant OR the owning startup admin
class ApplicationRepository {
  ApplicationRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _db.collection('applications');

  /// Submits a new application. Throws if the write is denied (e.g. the
  /// student already applied and a uniqueness rule/index rejects it, or
  /// Firestore rules reject the payload).
  Future<String> submitApplication({
    required String opportunityId,
    required String opportunityTitle,
    required String startupId,
    required String startupName,
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String message,
  }) async {
    final application = Application(
      id: '',
      opportunityId: opportunityId,
      opportunityTitle: opportunityTitle,
      startupId: startupId,
      startupName: startupName,
      studentId: studentId,
      studentName: studentName,
      studentEmail: studentEmail,
      message: message,
      status: ApplicationStatus.pending,
      createdAt: DateTime.now(),
    );
    final ref = await _applications.add(application.toCreateMap());
    return ref.id;
  }

  /// Live stream of the current student's own applications, most recent
  /// first.
  Stream<List<Application>> myApplicationsStream(String studentId) {
    return _applications
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Application.fromDoc).toList());
  }

  /// Live stream of every application submitted for one opportunity —
  /// used by a startup admin reviewing candidates.
  Stream<List<Application>> forOpportunityStream(String opportunityId) {
    return _applications
        .where('opportunityId', isEqualTo: opportunityId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Application.fromDoc).toList());
  }

  /// Whether [studentId] has already applied to [opportunityId] — used to
  /// disable the "Apply" button and avoid duplicate submissions.
  Future<bool> hasApplied({
    required String opportunityId,
    required String studentId,
  }) async {
    final result = await _applications
        .where('opportunityId', isEqualTo: opportunityId)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<void> updateStatus(String applicationId, ApplicationStatus status) {
    return _applications.doc(applicationId).update({'status': status.name});
  }
}