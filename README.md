# flutter_01-Firebase_Notes

## 01. Overview

A cross-platform notes application built with Flutter and Firebase, following professional development practices and a scalable project structure.

The project is being developed incrementally, with and emphasis on maintainability, security, automated testing, and production-ready development workflows.

Supported platforms:

* iOS
* Android
* Web

---

## 02. Features

### Application
- Note domain model and data structure
- Firebase Authentication
- Real-time notes data stream
- User-owned notes
- Secure data access through Firestore Security Rules

### Security
- Authentication-based access control
- Document ownership validation through ownerId
- Firestore document scheme validation
- Protected create, read, update, and delete operations
- Automated Security Rules tests

### Quality && Automation
- Static code analysis
- Automated Flutter tests
- Firestore Security Rules unit tests
- Firebase Emulator Suite
- GitHub Actions workflows
- CI/CD workflow foundations

---

## 03. Tech Stack

### Frontend
- Flutter 
- Dart

### Backend
- Firebase
- Firebase Authentication
- Cloud Firestore
- Firebase CLI
- FlutterFire CLI
- Firebase Emulator Suite

### Testing
- Flutter Test
- Node.js Test Runner
- @firebase/rules-unit-testing
- Firestore Emulator

### Development
- Git/Github
- FVM
- GitHub Actions

---

## 04. Requirements

Flutter 3.47.1
Dart 3.13.1
Git
FVM
Node.js and npm
Java JDK 11+ (for Firebase Emulator Suite)
Firebase CLI
FlutterFire CLI

Firebase project access is required for connecting to the production Firebase environment.

---

## 05. Supported Platforms

- iOS
- Android
- Web

---

## 06. Setup

Clone repository:
```bash
git clone https://github.com/danilot390/flutter_01-Firebase_Notes.git
cd flutter_01-Firebase_Notes
```

Install the configured Flutter SDK:
```bash
fvm install
```

Get dependencies:
```bash
fvm flutter pub get 
```

Verify the environment:
```bash
fvm flutter doctor
```

Configure Firebase, authenticate:
```bash
firebase login
```
Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

Configure the Flutter application with your Firebase poroject:
```bash
flutterfire configure
```
Select the Firebase project and the platforms you intend to support.
This generates the Firebase configuration used by the Flutter application, including firebase_options.dart.

Deploy firestore security rules 
```bash
firebase project:list
firebase use <your-project-id>
firebase deploy --only firestore:rules
```

Run static analysis:
```bash
fvm flutter analyze
```

Run tests:
```bash
fvm flutter test
```

Run the application:
```bash
fvm flutter run
```

---

## 07. Development Commands

Format Code
```Flutter
fvm dart format .
```

Analyze Code
```Flutter
fvm flutter analyze
```

Run Tests
```Flutter 
fvm flutter test
```

Run everything:
```Flutter
fvm dart format .
fvm flutter analyze
fvm flutter test
```

---

## 08. Firebase & Firestore

### 8.1 Firestore Data Structure
Notes are stored in a top-level Firestore collection.

```tree
notes/
  └── {noteId}
      ├── title
      ├── content
      ├── ownerId
      ├── createdAt
      └── updatedAt
```

### 8.2 Security Rules
Firestore Security Rules are maintained in `firebase/firestore.rules`.

The rules enforce:
- Authenticated access
- Note ownership validation
- Document scheme validation
- Title and content constraints
- Server-controlled timestamp
- Immutable ownership and creation timestamp
- Authorized read, create, update, and delete operations

Redeploy rules
```bash
firebase deploy --only firestore:rules
```

Firestore Security Rules are not query filters. Queries must already satisfy the access conditions defined by the rules.

---

## 09.Firestore Security Rules Testing

Security rules are tested independently using the Firebase Emulator Suite and Node.js test runner, test location `firebase/rules-tests/`

Install Test Dependencies
```bash 
npm install --save-dev --prefix firebase/rules-tests @firebase/rules-unit-testing firebase
```

Run Security Rules Tests
```bash
firebase emulators:exec --project demo-notes --only firestore "npm --prefix firebase/rules-tests test"
```

The security rules test suite validates:
- Anonymous users cannot read notes.
- Users can create their own notes.
- Users cannot create notes for another user.
- Invalid note documents are rejected.
- Users can read their own notes.
- Users cannot read another user's notes.
- Users can query only their own notes.
- Unfiltered note queries are rejected.
- Users can update their own notes.
- Users cannot change note ownership.
- Users cannot change creation timestamps.
- Users can delete their own notes.
- Users cannot delete another user's notes.
- Users cannot update another user's notes.

---

## 10.Project Strucure

```tree
├── .github
|   └── ISSUE_TEMPLATE
│       ├── bug_report.md
│       └── feature_request.md
│   └── workflows
│       ├── release-please.yml
│       └── verify.yml
├── android/
├── build/
├── docs
│   └── decisions
├── firebase
|   ├── firestore.rules
│   └── rules-tests/
├── ios/
├── lib/
├── linux/
├── macos/
├── test/
├── web/
├── windows/
├── .editorconfig
├── .fvmrc
├── .gitignore
├── .metadata
├── LICENSE
├── CONTRIBUTING.md
├── CHANGEGLOG.md
├── README.md
├── analysis_options.yaml
├── pubspec.lock
└── pubspec.yaml
```

---

## 11. Development Workflow

```bash
Implement code -> Format -> Static analyse -> Flutter tests -> Rule tests -> Deploy rules -> Review -> GitHub actions automation
```

## License

This project is lisenced under the MIT License.

See the LICENSE file for details.