import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

/// Wraps Firebase Auth + the `users` Firestore collection so the rest of
/// the app never talks to Firebase SDKs directly. This is the seam that
/// makes state management (Riverpod) and UI testable independently of
/// Firebase.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  /// Live stream of the signed-in user's Firestore profile document.
  /// Powers role-based routing and reactive UI (e.g. verification badges).
  Stream<AppUser?> userDataStream(String uid) {
    return _usersCol.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return AppUser.fromMap(uid, snap.data()!);
    });
  }

  Future<AppUser?> fetchUserData(String uid) async {
    final snap = await _usersCol.doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return AppUser.fromMap(uid, snap.data()!);
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Creates the Auth account AND the corresponding `users/{uid}` Firestore
  /// document in one flow, so every authenticated user always has a
  /// matching profile doc (no orphaned auth accounts).
  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final profile = AppUser(
      uid: uid,
      name: name,
      email: email,
      role: role,
    );
    await _usersCol.doc(uid).set(profile.toMap());
    await credential.user!.updateDisplayName(name);

    return credential;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// Links a startup_admin user to a startup they just created. Uses
  /// arrayUnion so an admin can own more than one startup over time
  /// without this call clobbering earlier ones.
  Future<void> attachStartupId(String uid, String startupId) {
    return _usersCol.doc(uid).update({
      'startupIds': FieldValue.arrayUnion([startupId]),
    });
  }

  /// Adds or removes a single opportunity id from the student's
  /// `bookmarks` array. Uses Firestore's arrayUnion/arrayRemove so
  /// concurrent toggles from other devices never clobber each other.
  Future<void> setBookmark({
    required String uid,
    required String opportunityId,
    required bool bookmarked,
  }) {
    return _usersCol.doc(uid).update({
      'bookmarks': bookmarked
          ? FieldValue.arrayUnion([opportunityId])
          : FieldValue.arrayRemove([opportunityId]),
    });
  }

  /// Updates editable profile fields (name, skills) for the signed-in
  /// user. Email/role are intentionally not editable here.
  Future<void> updateProfile({
    required String uid,
    String? name,
    List<String>? skills,
  }) {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (skills != null) updates['skills'] = skills;
    if (updates.isEmpty) return Future.value();
    return _usersCol.doc(uid).update(updates);
  }
}