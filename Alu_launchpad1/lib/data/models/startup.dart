import 'package:cloud_firestore/cloud_firestore.dart';

enum VerificationStatus { pending, verified, rejected }

VerificationStatus verificationStatusFromString(String value) {
  switch (value) {
    case 'verified':
      return VerificationStatus.verified;
    case 'rejected':
      return VerificationStatus.rejected;
    case 'pending':
    default:
      return VerificationStatus.pending;
  }
}

String verificationStatusToString(VerificationStatus status) {
  switch (status) {
    case VerificationStatus.verified:
      return 'verified';
    case VerificationStatus.rejected:
      return 'rejected';
    case VerificationStatus.pending:
      return 'pending';
  }
}

/// Mirrors a document in the top-level `startups` collection.
class Startup {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final String category; // e.g. "Tech", "Agri", "Media"
  final VerificationStatus verificationStatus;
  final String verificationNote; // e.g. ALU club registration reference
  final List<String> adminUids;
  final DateTime? createdAt;

  const Startup({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    required this.category,
    required this.verificationStatus,
    this.verificationNote = '',
    this.adminUids = const [],
    this.createdAt,
  });

  factory Startup.fromMap(String id, Map<String, dynamic> map) {
    return Startup(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      logoUrl: map['logoUrl'] as String?,
      category: map['category'] as String? ?? 'General',
      verificationStatus: verificationStatusFromString(
        map['verificationStatus'] as String? ?? 'pending',
      ),
      verificationNote: map['verificationNote'] as String? ?? '',
      adminUids: List<String>.from(map['adminUids'] as List? ?? const []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'category': category,
      'verificationStatus': verificationStatusToString(verificationStatus),
      'verificationNote': verificationNote,
      'adminUids': adminUids,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }
}
