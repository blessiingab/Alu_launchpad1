# ALU LaunchPad

A Flutter + Firebase app that connects ALU students with opportunities — internships, freelance work, and project roles — posted by verified, student-run startups inside the ALU community.

Today opportunities move through WhatsApp groups and word of mouth: nothing is tracked, and there's no way to tell whether a "startup" posting a role is actually a recognized ALU startup. LaunchPad fixes that with one rule enforced both in the UI and in Firestore Security Rules: **a startup can't post until it's verified**, and it can never verify itself.

## What it does

- **Students** browse a live feed of open opportunities, filter by type (internship / job / volunteer / project), bookmark ones they like, and apply with a short message. The Apply button reflects a live check against their own applications, so it can't go stale or double-submit.
- **Startups** land on a dashboard once verified, post and manage their own opportunities, and review applicants — marking each one reviewed, then accepted or rejected. The student sees that status update in real time, no refresh needed.
- **Both sides** get in-app notifications when something changes on their side — a new application, a status change.
- **Verification is manual today.** There's no in-app admin queue yet — an operator flips a startup's `verificationStatus` to `verified` directly in the Firebase console, and the app reacts to that change on its own. See [Roadmap](#roadmap) for where this is headed.

## Tech stack

| Layer | Choice |
|---|---|
| App framework | Flutter |
| Backend | Firebase Authentication + Cloud Firestore |
| State management | [`flutter_riverpod`](https://riverpod.dev) — `StreamProvider`s over live Firestore data, `AsyncNotifier` controllers for writes, `StateProvider` for small UI state |
| Navigation | [`go_router`](https://pub.dev/packages/go_router), with a single central redirect driven by auth + role state |
| Fonts | Google Fonts (Space Grotesk / Work Sans) |

There is no `flutter_bloc` dependency — an earlier design pass considered Bloc/Cubit, but the shipped app is Riverpod end to end.

## Architecture

Feature-first folders on top of one shared data layer. Widgets never talk to Firebase directly — only repositories do, and everything else reads them through typed Riverpod providers.

```
lib/
├── main.dart                 # Firebase.initializeApp + runApp(ProviderScope(...))
├── core/
│   ├── routing/               # app_router.dart — GoRouter + auth/role redirect
│   └── theme/                 # app_theme.dart — "Savanna at Dusk" design tokens
├── data/
│   ├── models/                 # AppUser, Startup, Opportunity, Application, AppNotification
│   └── repositories/           # Auth-, Startup-, Opportunity-, Application-, NotificationRepository
├── dev/
│   └── seed_firestore.dart     # local seeding script, not shipped in the app
├── shared/
│   └── widgets/                # OpportunityCard, StatusBadge, PrimaryButton, SkillChipInput, ...
└── features/
    ├── auth/                   # login, signup, role selection
    ├── student/                # bottom-nav shell, profile, bookmarks
    ├── startup/                # create/setup startup, dashboard, manage postings
    ├── opportunities/          # student feed, detail screen, providers
    ├── applications/           # apply form, applicant review, providers
    └── notifications/          # notifications feed, providers
```

## Firestore data model

Three collections carry the app: `users`, `startups`, `opportunities`, plus a top-level `applications` collection and a `notifications` collection.

- **`users/{uid}`** — `name`, `email`, `role` (`student` | `startup_admin`), `skills`, `startupIds`, and `bookmarks` — a plain array of opportunity IDs, updated with `arrayUnion`/`arrayRemove`. Bookmarks are *not* a separate collection.
- **`startups/{startupId}`** — profile info plus `verificationStatus` (`pending` | `verified`), owned by one or more `adminUids`.
- **`opportunities/{opportunityId}`** — `startupId`, `title`, `description`, `type`, `requiredSkills`, `status`, `createdAt`. Creating one requires the owning startup to already be verified.
- **`applications/{autoId}`** — Firestore auto-generated ID, storing `opportunityId`, `startupId`, `studentId`, `status`, a `message`, and a snapshot of the opportunity/startup names so a screen can render an application in one read. Duplicate applications are prevented by a live existence query (`hasApplied()`) before the Apply button is enabled, rather than a deterministic composite key.
- **`notifications/{id}`** — one document per notification, capped to the most recent 50 per user.

## Security rules

`firestore.rules` currently defines rules for `users`, `startups`, and `opportunities`:

- A user can create only their own profile and can never change their own `role` after signup.
- A startup admin can create and edit their own startup, but a comparison of old vs. new `verificationStatus` on every update means they can never verify themselves.
- Posting an opportunity requires the caller's startup to already be `verified`.

> **Known gap:** the `applications` and `notifications` collections the app actually reads and writes to don't yet have their own rules in this file. If you're picking this project back up, confirm what's deployed in the Firebase console matches `firestore.rules`, and add explicit rules for both before relying on them.

`firestore.indexes.json` intentionally defines no composite indexes — queries are kept to a single equality filter with any extra ordering done client-side, specifically to avoid needing one.

## Getting started

**Prerequisites**

- Flutter SDK 3.27+ (Dart ≥3.11.5, see `pubspec.yaml`)
- A Firebase project with Authentication (email/password) and Cloud Firestore enabled
- Android Studio / VS Code with the Flutter plugin, and an emulator or physical device

**Setup**

```bash
git clone https://github.com/blessiingab/Alu_launchpad1.git
cd Alu_launchpad1
flutter pub get
```

Wire up your own Firebase project (this repo does not ship real Firebase credentials):

1. Create a Firebase project and register an Android app for it.
2. Enable **Authentication** (email/password) and **Cloud Firestore**.
3. Run `flutterfire configure` (or manually drop in `google-services.json` / `firebase_options.dart`) to point the app at your project.
4. Deploy the rules and indexes in this repo: `firebase deploy --only firestore:rules,firestore:indexes` — then double-check the console against the gap noted above.
5. Optionally run `lib/dev/seed_firestore.dart` to seed some sample startups and opportunities.

```bash
flutter run
```

**Windows note:** you may need to enable Developer Mode to build (`start ms-settings:developers`). The first Firebase-enabled build can take a while — that's expected.

## Known limitations

- No push notifications — status changes are only visible while the app is open.
- No in-app messaging between startups and applicants.
- No pagination — the feed streams every open opportunity.
- No CV/portfolio attachments (Firebase Storage requires a billing account).
- No in-app verification queue — approving a startup is a manual Firestore edit.
- Android-only configuration.

## Roadmap

- FCM push notifications on application-status changes
- In-app messaging between startups and applicants
- Feed pagination with a `startAfterDocument()` cursor
- Interview scheduling
- An in-app admin queue for startup verification
- A real skills-match score / "For you" tab on the feed
- Persisted light/dark theme preference
- An analytics dashboard for admins (postings per category, time-to-review)

## Author

**Blessing Ingabire** — Software Engineering, African Leadership University

Built as a capstone project. This project is for educational purposes as part of ALU coursework.
