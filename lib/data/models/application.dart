import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus { pending, reviewed, accepted, rejected }

ApplicationStatus applicationStatusFromString(String value) {
  return ApplicationStatus.values.firstWhere(
    (s) => s.name == value,
    orElse: () => ApplicationStatus.pending,
  );
}

String applicationStatusLabel(ApplicationStatus status) {
  switch (status) {
    case ApplicationStatus.pending:
      return 'Pending review';
    case ApplicationStatus.reviewed:
      return 'Reviewed';
    case ApplicationStatus.accepted:
      return 'Accepted';
    case ApplicationStatus.rejected:
      return 'Not selected';
  }
}

class Application {
  const Application({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.message,
    required this.status,
    required this.createdAt,
    this.portfolioLink,
  });

  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String message;
  final ApplicationStatus status;
  final DateTime createdAt;
  final String? portfolioLink;

  factory Application.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Application(
      id: doc.id,
      opportunityId: data['opportunityId'] as String? ?? '',
      opportunityTitle: data['opportunityTitle'] as String? ?? '',
      startupId: data['startupId'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      studentId: data['studentId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? '',
      studentEmail: data['studentEmail'] as String? ?? '',
      message: data['message'] as String? ?? '',
      status: applicationStatusFromString(data['status'] as String? ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      portfolioLink: data['portfolioLink'] as String?,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'startupId': startupId,
      'startupName': startupName,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'message': message,
      'portfolioLink': (portfolioLink == null || portfolioLink!.trim().isEmpty)
          ? null
          : portfolioLink!.trim(),
      'status': ApplicationStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}