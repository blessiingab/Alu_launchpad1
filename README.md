ALU LaunchPad

ALU LaunchPad is a mobile application developed to connect students, startups, mentors, and investors within the African Leadership University (ALU) community. The platform enables startups to showcase opportunities, students to discover and apply for internships or projects, mentors to guide aspiring entrepreneurs, and investors to connect with promising startups.

The application is built using **Flutter**, **Firebase** (Authentication, Cloud Firestore, and Storage), **Riverpod** for state management, and **Material 3** to provide a modern, responsive, and user-friendly experience.

---

Features

| Module | Description |
| --- | --- |
| Authentication | Secure email/password registration, login, password reset, and email verification using Firebase Authentication. |
| Student Dashboard | Browse opportunities, manage applications, save favorites, and update personal profile information. |
| Startup Dashboard | Create and manage startup profiles, publish opportunities, review applicants, and monitor engagement. |
| Opportunity Management | Create, edit, delete, and manage internship or project opportunities. |
| Search & Filtering | Search opportunities and filter by category, skills, location, or opportunity type. |
| Applications | Students can apply for opportunities and monitor their application status in real time. |
| Profile Management | Users can update their personal information, skills, experience, and profile picture. |
| Notifications | Receive updates about applications, opportunities, and platform activities. |
| Theme Support | Supports Light and Dark mode with Material 3 design principles. |

---

Architecture

The project follows a feature-first architecture to improve scalability, readability, and maintainability.

```text
lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── services/
│   ├── theme/
│   └── utils/
│
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
│
├── features/
│   ├── authentication/
│   ├── student/
│   ├── startup/
│   ├── mentor/
│   ├── investor/
│   ├── opportunities/
│   ├── chat/
│   ├── notifications/
│   └── profile/
│
├── shared/
│   ├── providers/
│   └── widgets/
│
└── firebase_options.dart
```

The application separates business logic, data models, services, and presentation into individual modules, making it easier to maintain and extend as the project grows.

---

Technologies Used

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Riverpod
- Go Router
- Material 3
- Google Fonts

---

Database Structure

Main Firestore collections include:

- `users/{userId}` – Stores user profile information, role, skills, and account details.
- `startups/{startupId}` – Startup profiles and company information.
- `opportunities/{opportunityId}` – Internship, project, and job opportunities.
- `applications/{applicationId}` – Student applications submitted for opportunities.
- `notifications/{notificationId}` – User notifications and updates.
- `messages/{chatId}` – Chat conversations between users.

Firebase Security Rules ensure authenticated access while protecting user data and restricting unauthorized actions.

---

Getting Started

Before running the project, ensure the following tools are installed:

- Flutter SDK (3.x or later)
- Dart SDK
- Android Studio or Visual Studio Code
- Firebase Project
- Android Emulator or Physical Device

---

Installation

Clone the repository.

```bash
git clone https://github.com/blessiingab/alu-launchpad.git
```

Navigate to the project directory.

```bash
cd alu-launchpad
```

Install project dependencies.

```bash
flutter pub get
```

Run the application.

```bash
flutter run
```

---

Firebase Configuration

1. Create a Firebase project.
2. Register the Android and/or iOS application.
3. Enable Firebase Authentication.
4. Enable Cloud Firestore.
5. Enable Firebase Storage.
6. Download the Firebase configuration files or configure `firebase_options.dart`.
7. Run the application.

---

Future Improvements

- Real-time messaging
- Push notifications
- AI-powered opportunity recommendations
- Mentor matching system
- Investor dashboard
- Startup analytics
- Resume builder
- Event management
- Community discussion forums
- In-app video meetings

---

Development Principles

The project was developed with the following objectives:

- Clean and maintainable code
- Modular architecture
- Reusable widgets
- Responsive user interface
- Scalable Firebase integration
- Consistent Material 3 design
- Easy maintenance and future expansion

---

Author

Blessing Ingabire

Software Engineering Student

African Leadership University

---

Acknowledgements

This project was developed as part of the Software Engineering program at the African Leadership University. It demonstrates the practical application of Flutter development, Firebase integration, and modern mobile application architecture to address challenges in connecting students with entrepreneurial opportunities.

---

License

This project was created for educational purposes as part of coursework at the African Leadership University.