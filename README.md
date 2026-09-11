# flutter_01-Firebase_Notes

## 01. Overview

A small cross platform notes application buitl with Flutter and Firebase.

---

## 02. Features

- CI/CD (Continuous Integration - Continuous Delivery)

---

## 03. Tech Stack

### Frontend
- Flutter 
- Dart

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

---

## 05. Supported Platforms

The project is intended to run on:

- iOS
- Android
- Web

---

## 06. Setup

Clone the repository:
```cmd
git clone https://github.com/danilot390/flutter_01-Firebase_Notes.git
```

Install the configured Flutter SDK:
```cmd
fvm install
```

Get dependencies:
```cmd
fvm flutter pub get 
```

Verify the environment:
```
fvm flutter doctor
```

Run static analysis:
```cmd
fvm flutter analyze
```

Run tests:
```cmd
fvm flutter test
```

Run the application:
```cmd
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

## 08. Project Strucure

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
├── flutter_01_firebase_notes.iml
├── pubspec.lock
└── pubspec.yaml
```

---

## License

This project is lisenced under the MIT License.

See the LICENSE file for details.