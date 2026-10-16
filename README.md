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
- Access to a Firebase project and its restricted client API keys.
- A Firestore database with rules that allow this app to read and write the `machines` collection.

The Firebase project identifiers are in `lib/firebase_options.dart`. API keys are not stored in tracked source files. Create a local config file from the example and replace its placeholders with the appropriate keys from your Firebase project:

```bash
cp .env.firebase.example.json .env.firebase.json
```

Restrict each Google API key to the correct app/platform and only the APIs it needs. The local `.env.firebase.json` file is ignored by Git. If you do not have access to this Firebase project, use your own Firebase project and update the Firebase app identifiers in `lib/firebase_options.dart`.

If the required key is missing or still has the example placeholder, the app now displays a **Firebase setup required** message instead of a blank page. For Chrome, set `FIREBASE_API_KEY_WEB` to a valid key from the Firebase web app configuration.

The app does not currently implement user sign-in. Firestore rules that require an authenticated user will therefore reject its requests. Set up rules appropriate for a controlled lab environment, and add authentication and restrictive rules before using this app with real data.

## Run in Visual Studio Code

Open this project folder (`grocery_shop_management`) in VS Code, then open **Terminal → New Terminal** and run:

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=.env.firebase.json
```

If Flutter cannot launch Chrome automatically, start the web server instead:

```bash
flutter run -d web-server --release --web-hostname 127.0.0.1 --web-port 8765 --dart-define-from-file=.env.firebase.json
```

Then open `http://127.0.0.1:8765` in a browser.

To create a deployable web build:

```bash
flutter build web --dart-define-from-file=.env.firebase.json
```

Linux desktop is not configured in `lib/firebase_options.dart`; its Firebase options currently throw `UnsupportedError`. Use Chrome unless you add and configure Linux Firebase options. Android is initialized from the Dart Firebase options, so a checked-in `google-services.json` is not required.

> **API-key security:** Firebase client API keys are visible in built web and mobile apps; putting them in a local build config keeps them out of Git, but does not make them secret at runtime. Restrict them in Google Cloud Console. The previously committed keys remain visible in earlier Git history and must be rotated/restricted or revoked; deleting them from the latest version does not erase historical commits.

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
flutter build web --dart-define-from-file=.env.firebase.json
```

There is currently no `test/` directory, so `flutter test` cannot run a test suite until tests are added.

Latest local check:

- `flutter analyze` — passed with no issues.
- `flutter build web --dart-define-from-file=.env.firebase.json` — passed.
- Browser smoke test — the web server responds, and the app displays a setup message because `FIREBASE_API_KEY_WEB` is still the example placeholder. After configuring a valid key, Firestore access/rules still need to be checked.
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
