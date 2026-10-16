# Machine Health Monitor

A Flutter cloud-computing lab project that displays machine status and sensor readings stored in Firebase Cloud Firestore. The app listens to Firestore in real time, so changes to machine documents appear on the dashboard without restarting the app.

> **Project-name note:** The folder and package are named `grocery_shop_management`, but the app currently launched from `lib/main.dart` is a machine health monitor. The customer model, service, and screen in `lib/models`, `lib/services`, and `lib/screens` are not connected to the current app.

## Features

- Shows counts of running, idle, and error-state machines.
- Lists machines and opens a detail page with temperature, vibration, and a health warning.
- Subscribes to the `machines` Firestore collection for live updates.
- Adds or refreshes three sample machine documents from the dashboard.
- Shows loading, empty, and Firestore error states.

The health warning is shown when temperature is above **80 °C** or vibration is above **5 mm/s**.

## Technology

- Flutter and Dart
- Firebase Core
- Cloud Firestore

## Requirements

- Flutter SDK (the project requires Dart `^3.12.2`).
- Google Chrome for the tested web target.
- Access to the Firebase project configured in `lib/firebase_options.dart`.
- A Firestore database with rules that allow this app to read and write the `machines` collection.

The Firebase configuration files identify a particular Firebase project. If you do not have access to it, configure your own Firebase project and regenerate the platform options before running the app. Do not use public Firestore read/write rules for a production app.

The app does not currently implement user sign-in. Firestore rules that require an authenticated user will therefore reject its requests. Set up rules appropriate for a controlled lab environment, and add authentication and restrictive rules before using this app with real data.

## Run in Visual Studio Code

Open this project folder (`grocery_shop_management`) in VS Code, then open **Terminal → New Terminal** and run:

```bash
flutter pub get
flutter run -d chrome
```

If Flutter cannot launch Chrome automatically, start the web server instead:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8765
```

Then open `http://127.0.0.1:8765` in a browser.

To create a deployable web build:

```bash
flutter build web
```

Linux desktop is not configured in `lib/firebase_options.dart`; its Firebase options currently throw `UnsupportedError`. Use Chrome unless you add and configure Linux Firebase options. Android and iOS configuration files are present, but have not been verified as part of this project check.

## Firestore data

The app reads and writes documents in the `machines` collection. Use these fields:

| Field | Type | Example |
| --- | --- | --- |
| `name` | string | `Machine 01` |
| `state` | string | `running`, `idle`, or `error` |
| `temperature` | number | `72.5` |
| `vibration` | number | `2.4` |
| `updatedAt` | timestamp | Set by the sample-data action |

Select **Add Sample Machines** on the empty screen, or use the cloud-upload button in the app bar, to write three sample documents. The dashboard requires Firestore access; a successful build alone does not confirm Firebase credentials, database setup, or security rules.

## Project layout

```text
lib/
  main.dart                App entry point, machine dashboard, details, and sample data
  firebase_options.dart   Firebase settings for supported app platforms
  models/customer.dart    Customer data model (not used by the active app)
  services/customer_service.dart  Customer Firestore operations (not used by the active app)
  screens/customers_screen.dart   Customer UI (not used by the active app)
```

## Checks

Run these from the project directory:

```bash
flutter analyze
flutter test
flutter build web
```

There is currently no `test/` directory, so `flutter test` cannot run a test suite until tests are added.

Latest local check:

- `flutter analyze` — passed with no issues.
- `flutter build web` — passed.
- Browser smoke test — the dashboard UI starts, but Firestore returned `permission-denied` for the configured Firebase project. Live data requires valid project access and Firestore rules.
- `flutter test` — not available yet because the project has no `test/` directory.

## Screenshot for a lab submission

1. Configure Firestore access, run the app, and populate the dashboard with the sample machines.
2. Take a screenshot using your operating system's screenshot tool.
3. Save it in this repository as `screenshots/dashboard.png`.
4. Once the image exists, display it here by adding:

   ```markdown
   ![Machine Health Monitor dashboard](screenshots/dashboard.png)
   ```

The screenshot is not included yet because the current Firebase project denies access. After saving a working screenshot, use **Source Control** in VS Code to commit and push it. Alternatively, from the repository root:

```bash
git add README.md screenshots/dashboard.png
git commit -m "Add machine health dashboard screenshot"
git push
```

Replace the screenshot path if you save the image somewhere else.
