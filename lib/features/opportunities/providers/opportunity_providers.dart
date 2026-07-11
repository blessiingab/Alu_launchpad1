import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/opportunity.dart';
import '../../../data/repositories/opportunity_repository.dart';
import '../../auth/providers/auth_providers.dart';
import '../../startup/providers/startup_providers.dart';

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepository();
});

/// Every open opportunity, across all verified startups. This is the
/// student feed's data source.
final openOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  return ref.watch(opportunityRepositoryProvider).openOpportunitiesStream();
});

/// One opportunity by id, live — used by the detail screen so it stays
/// current if e.g. a startup closes it while the student is viewing it.
final opportunityByIdProvider =
    StreamProvider.family<Opportunity?, String>((ref, id) {
  return ref.watch(opportunityRepositoryProvider).byIdStream(id);
});

/// Everything across every startup the signed-in admin owns (open +
/// closed) — powers the dashboard + manage-opportunities screen.
final myOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  final startups = ref.watch(myStartupsProvider).value ?? const [];
  if (startups.isEmpty) return Stream.value(const []);
  final ids = startups.map((s) => s.id).toList();
  return ref.watch(opportunityRepositoryProvider).byStartupIdsStream(ids);
});

/// Free-text search query for the student feed. Kept here rather than in
/// widget state so it survives tab switches within the student shell.
final opportunitySearchProvider = StateProvider<String>((ref) => '');

/// Optional type filter for the student feed. Null = show every type.
final opportunityTypeFilterProvider =
    StateProvider<OpportunityType?>((ref) => null);

/// Derived, filtered feed — the actual list the home screen renders.
final filteredOpportunitiesProvider = Provider<AsyncValue<List<Opportunity>>>(
  (ref) {
    final async = ref.watch(openOpportunitiesProvider);
    final query = ref.watch(opportunitySearchProvider).trim().toLowerCase();
    final typeFilter = ref.watch(opportunityTypeFilterProvider);

    return async.whenData((items) {
      return items.where((o) {
        final matchesType = typeFilter == null || o.type == typeFilter;
        if (!matchesType) return false;
        if (query.isEmpty) return true;
        return o.title.toLowerCase().contains(query) ||
            o.startupName.toLowerCase().contains(query) ||
            o.skillsRequired.any((s) => s.toLowerCase().contains(query));
      }).toList();
    });
  },
);

/// Resolves the current student's bookmarked opportunity ids into full
/// Opportunity objects. Re-fetches whenever the bookmarks array changes.
final bookmarkedOpportunitiesProvider = FutureProvider<List<Opportunity>>((ref) async {
  final userData = ref.watch(currentUserDataProvider).value;
  if (userData == null || userData.bookmarks.isEmpty) return const [];
  final repo = ref.watch(opportunityRepositoryProvider);
  final results = await Future.wait(userData.bookmarks.map(repo.fetch));
  return results.whereType<Opportunity>().toList();
});

class OpportunityFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// [startupId]/[startupName] are explicit now that an admin can own
  /// more than one startup — the caller (post_opportunity_screen) is
  /// responsible for having the admin pick which one, when they have
  /// more than one verified startup to choose from.
  Future<void> post({
    required String startupId,
    required String startupName,
    required String title,
    required String description,
    required OpportunityType type,
    required List<String> skillsRequired,
    required String location,
    required WorkMode workMode,
    DateTime? deadline,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(opportunityRepositoryProvider);
      await repo.create(Opportunity(
        id: '',
        startupId: startupId,
        startupName: startupName,
        title: title,
        description: description,
        type: type,
        skillsRequired: skillsRequired,
        location: location,
        workMode: workMode,
        deadline: deadline,
      ));
    });
  }

  Future<void> editOpportunity({
    required String id,
    required String title,
    required String description,
    required OpportunityType type,
    required List<String> skillsRequired,
    required String location,
    required WorkMode workMode,
    DateTime? deadline,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(opportunityRepositoryProvider);
      await repo.update(id, {
        'title': title,
        'description': description,
        'type': opportunityTypeToString(type),
        'skillsRequired': skillsRequired,
        'location': location,
        'workMode': workModeToString(workMode),
        'deadline': deadline == null ? null : Timestamp.fromDate(deadline),
      });
    });
  }

  Future<void> toggleStatus(String id, OpportunityStatus current) async {
    final repo = ref.read(opportunityRepositoryProvider);
    final next = current == OpportunityStatus.open
        ? OpportunityStatus.closed
        : OpportunityStatus.open;
    await repo.setStatus(id, next);
  }
}

final opportunityFormControllerProvider =
    AsyncNotifierProvider<OpportunityFormController, void>(
  OpportunityFormController.new,
);

/// Toggles an opportunity id in/out of the current student's bookmarks.
class BookmarkController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> toggle(String opportunityId) async {
    final authRepo = ref.read(authRepositoryProvider);
    final userData = ref.read(currentUserDataProvider).value;
    if (userData == null) return;

    final isBookmarked = userData.bookmarks.contains(opportunityId);
    await authRepo.setBookmark(
      uid: userData.uid,
      opportunityId: opportunityId,
      bookmarked: !isBookmarked,
    );
  }
}

final bookmarkControllerProvider =
    AsyncNotifierProvider<BookmarkController, void>(BookmarkController.new);