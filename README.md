# ALU LaunchPad

ALU LaunchPad is a Flutter and Firebase application that connects African Leadership University (ALU) students with internships, freelance work, and project opportunities posted by verified student-led startups within the ALU community.



> **A startup cannot post opportunities until it has been verified, and it cannot verify itself.**

---

# What It Does

### For Students

* Browse a live feed of available opportunities.
* Filter opportunities by type (Internship, Job, Volunteer, or Project).
* Save opportunities for later using bookmarks.
* Apply with a short message.
* Prevent duplicate applications through a real-time application check.
* Track the status of submitted applications in real time.

### For Startups

* Access a startup dashboard after verification.
* Create, edit, and manage opportunities.
* View applications submitted by students.
* Review applications and update their status (Reviewed, Accepted, or Rejected).
* Changes are reflected instantly for students through Firestore's real-time updates.

### For Everyone

* Receive in-app notifications for important events, such as:

  * New applications
  * Application status changes
* Enjoy a fully real-time experience powered by Cloud Firestore.

### Startup Verification

Verification is currently performed manually.

There is no in-app administrator dashboard yet. Instead, an administrator updates a startup's `verificationStatus` field directly from the Firebase Console. Once the status changes to `verified`, the application automatically updates the user experience without requiring any code changes or app restart.

See the **Roadmap** section for planned improvements.

---

# Tech Stack

| Layer            | Technology                                |
| ---------------- | ----------------------------------------- |
| Framework        | Flutter                                   |
| Language         | Dart                                      |
| Backend          | Firebase Authentication & Cloud Firestore |
| State Management | Flutter Riverpod                          |
| Navigation       | GoRouter                                  
  |

The application is built entirely with **Riverpod**. Although an earlier prototype considered Bloc/Cubit, the final implementation uses Riverpod throughout the project.

---

# Architecture

The project follows a feature-first architecture layered over a shared data layer.

Widgets never communicate directly with Firebase. Instead, all Firebase operations pass through repository classes, which are exposed to the UI using Riverpod providers.

```text
lib/
├── main.dart                 # Firebase initialization and ProviderScope
├── core/
│   ├── routing/              # GoRouter configuration
│   └── theme/                # App theme
├── data/
│   ├── models/               # AppUser, Startup, Opportunity, Application...
│   └── repositories/         # Firebase repositories
├── dev/
│   └── seed_firestore.dart   # Local database seeding script
├── shared/
│   └── widgets/              # Reusable UI components
└── features/
    ├── auth/
    ├── student/
    ├── startup/
    ├── opportunities/
    ├── applications/
    └── notifications/
```

---

# Firestore Data Model

The application stores its data in five main collections.

### `users/{uid}`

Stores user profile information.

Fields include:

* `name`
* `email`
* `role` (`student` or `startup_admin`)
* `skills`
* `startupIds`
* `bookmarks`

Bookmarks are stored directly as an array of opportunity IDs using Firestore's `arrayUnion()` and `arrayRemove()` operations rather than as a separate collection.

---

### `startups/{startupId}`

Stores startup information, including:

* Company profile
* Administrator IDs
* Verification status (`pending` or `verified`)

Each startup can have one or more administrators.

---

### `opportunities/{opportunityId}`

Stores internship and project opportunities.

Fields include:

* `startupId`
* `title`
* `description`
* `type`
* `requiredSkills`
* `status`
* `createdAt`

Only verified startups are allowed to create opportunities.

---

### `applications/{applicationId}`

Stores applications submitted by students.

Each document contains:

* `studentId`
* `startupId`
* `opportunityId`
* `status`
* `message`
* Snapshot fields such as startup name and opportunity title

Applications use Firestore's auto-generated document IDs.

Duplicate applications are prevented through a real-time existence check before enabling the **Apply** button.

---

### `notifications/{notificationId}`

Stores user notifications.

Examples include:

* New application received
* Application accepted
* Application rejected
* Application under review

Each user keeps only their 50 most recent notifications.

---

# Firestore Security Rules

The project uses Firestore Security Rules to protect application data.

Current rules enforce the following:

* Users may create only their own profile.
* Users cannot change their assigned role after registration.
* Startup administrators can manage only startups they own.
* Startup administrators cannot change their own verification status.
* Only verified startups are allowed to create opportunities.
* Students may apply only using their own account.
* Startup administrators may view only applications submitted to their own startups.
* Only application status can be updated after submission.

> **Note:** Before deploying the application, ensure that the rules deployed to Firebase match the `firestore.rules` file in this repository.

---

# Getting Started

## Prerequisites

Before running the project, install:

* Flutter SDK 3.27 or later
* Dart SDK
* Android Studio or Visual Studio Code
* Firebase CLI
* FlutterFire CLI
* A Firebase project with Authentication and Firestore enabled

---

## Installation

Clone the repository.

```bash
git clone https://github.com/blessiingab/Alu_launchpad1.git
```

Navigate into the project.

```bash
cd Alu_launchpad1
```

Install dependencies.

```bash
flutter pub get
```

---

## Firebase Setup

This repository does not include production Firebase credentials.

To connect your own Firebase project:

1. Create a Firebase project.
2. Register your Android application.
3. Enable **Email/Password Authentication**.
4. Enable **Cloud Firestore**.
5. Run:

```bash
flutterfire configure
```

or manually add:

* `google-services.json`
* `firebase_options.dart`

Deploy Firestore rules and indexes.

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

Optionally seed the database using:

```bash
dart lib/dev/seed_firestore.dart
```

---

## Running the Application

```bash
flutter run
```

### Windows

Windows users may need to enable **Developer Mode** before building Flutter applications.

```bash
start ms-settings:developers
```

The first Firebase-enabled build may take several minutes.

---

# Known Limitations

* No Firebase Cloud Messaging (push notifications).
* No in-app chat between startups and applicants.
* Opportunity feed does not yet support pagination.
* CV and portfolio uploads are not implemented.
* Startup verification is still performed manually.
* Android is currently the primary supported platform.

---

# Roadmap

Future improvements include:

* Firebase Cloud Messaging (FCM)
* In-app messaging
* Feed pagination
* Interview scheduling
* Administrator verification dashboard
* AI-powered opportunity recommendations
* Persistent light and dark themes
* Analytics dashboard for startup administrators
* Resume and portfolio uploads
* Email notifications

---

# Author

**Blessing Ingabire**
Software Engineering Student
African Leadership University (ALU)

---

# License

This project was developed as part of the African Leadership University Software Engineering program and is intended for educational purposes.

If the project is released publicly, consider adding an open-source license such as the **MIT License** or **Apache License 2.0**.
