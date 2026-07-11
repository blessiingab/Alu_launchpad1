import 'package:cloud_firestore/cloud_firestore.dart';

enum OpportunityType { internship, job, volunteer, project }

OpportunityType opportunityTypeFromString(String value) {
  switch (value) {
    case 'job':
      return OpportunityType.job;
    case 'volunteer':
      return OpportunityType.volunteer;
    case 'project':
      return OpportunityType.project;
    case 'internship':
    default:
      return OpportunityType.internship;
  }
}

String opportunityTypeToString(OpportunityType type) {
  switch (type) {
    case OpportunityType.job:
      return 'job';
    case OpportunityType.volunteer:
      return 'volunteer';
    case OpportunityType.project:
      return 'project';
    case OpportunityType.internship:
      return 'internship';
  }
}

String opportunityTypeLabel(OpportunityType type) {
  switch (type) {
    case OpportunityType.job:
      return 'Job';
    case OpportunityType.volunteer:
      return 'Volunteer';
    case OpportunityType.project:
      return 'Project';
    case OpportunityType.internship:
      return 'Internship';
  }
}

/// How the work is done. Replaces the old `isRemote` boolean, which
/// couldn't represent hybrid arrangements.
enum WorkMode { onsite, remote, hybrid }

WorkMode workModeFromString(String value) {
  switch (value) {
    case 'remote':
      return WorkMode.remote;
    case 'hybrid':
      return WorkMode.hybrid;
    case 'onsite':
    default:
      return WorkMode.onsite;
  }
}

String workModeToString(WorkMode mode) {
  switch (mode) {
    case WorkMode.remote:
      return 'remote';
    case WorkMode.hybrid:
      return 'hybrid';
    case WorkMode.onsite:
      return 'onsite';
  }
}

String workModeLabel(WorkMode mode) {
  switch (mode) {
    case WorkMode.remote:
      return 'Remote';
    case WorkMode.hybrid:
      return 'Hybrid';
    case WorkMode.onsite:
      return 'In person';
  }
}

enum OpportunityStatus { open, closed }

OpportunityStatus opportunityStatusFromString(String value) {
  return value == 'closed' ? OpportunityStatus.closed : OpportunityStatus.open;
}

String opportunityStatusToString(OpportunityStatus status) {
  return status == OpportunityStatus.closed ? 'closed' : 'open';
}

/// Mirrors a document in the top-level `opportunities` collection.
///
/// `startupId` / `startupName` are denormalized onto the document itself
/// (rather than requiring a join against `startups` on every card render)
/// since opportunity feeds are read far more often than startup names
/// change.
class Opportunity {
  final String id;
  final String startupId;
  final String startupName;
  final String title;
  final String description;
  final OpportunityType type;
  final List<String> skillsRequired;
  final String location;
  final WorkMode workMode;
  final OpportunityStatus status;
  final DateTime? deadline;
  final DateTime? createdAt;

  const Opportunity({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.title,
    required this.description,
    required this.type,
    this.skillsRequired = const [],
    this.location = '',
    this.workMode = WorkMode.onsite,
    this.status = OpportunityStatus.open,
    this.deadline,
    this.createdAt,
  });

  /// True for both remote and hybrid — kept as a convenience getter for
  /// any UI that only cares "is there a remote component at all", rather
  /// than the full three-way distinction.
  bool get isRemote => workMode == WorkMode.remote || workMode == WorkMode.hybrid;

  factory Opportunity.fromMap(String id, Map<String, dynamic> map) {
    // Prefer the new `workMode` field; fall back to the legacy `isRemote`
    // boolean for documents written before this migration.
    final WorkMode resolvedMode;
    if (map['workMode'] is String) {
      resolvedMode = workModeFromString(map['workMode'] as String);
    } else {
      resolvedMode =
          (map['isRemote'] as bool? ?? false) ? WorkMode.remote : WorkMode.onsite;
    }

    return Opportunity(
      id: id,
      startupId: map['startupId'] as String? ?? '',
      startupName: map['startupName'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: opportunityTypeFromString(map['type'] as String? ?? 'internship'),
      skillsRequired: List<String>.from(map['skillsRequired'] as List? ?? const []),
      location: map['location'] as String? ?? '',
      workMode: resolvedMode,
      status: opportunityStatusFromString(map['status'] as String? ?? 'open'),
      deadline: (map['deadline'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startupId': startupId,
      'startupName': startupName,
      'title': title,
      'description': description,
      'type': opportunityTypeToString(type),
      'skillsRequired': skillsRequired,
      'location': location,
      'workMode': workModeToString(workMode),
      'status': opportunityStatusToString(status),
      'deadline': deadline == null ? null : Timestamp.fromDate(deadline!),
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }
}