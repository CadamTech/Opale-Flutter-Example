# Age Verification System in Flutter

This documentation guides you through the implementation of the Opale.io age verification solution in a Flutter application. The system utilizes an `InAppWebView` to display a web-based verification process, allowing for a seamless and integrated user experience.

## Getting Started

### Prerequisites
- Flutter SDK
- An IDE (VSCode, Android Studio, etc.)
- `flutter_inappwebview` package
- `permission_handler` package
- `crypto` package

Add the dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  permission_handler: ^11.3.0
  flutter_inappwebview: ^6.0.0
  crypto: ^3.0.3
```

# Implementation Overview

The implementation involves several key components and steps to integrate a secure and seamless age verification process within your Flutter app:

1. **Request Camera Permission**: The app starts by requesting camera access permissions from the user. This step is crucial for age verification processes that may require photo identification.

2. **Setup the Main Application Structure**: The application defines a basic Flutter app structure, starting with the main function that initializes the app and requests necessary permissions. It then loads the `MyApp` widget, which sets up the home screen of the app.

3. **Home Page with Verification Trigger**: The home page, represented by the `HomePage` widget, displays the current verification status and includes a button to initiate the age verification process.

4. **Age Verification via Web View**: When the user opts to start the verification, the app displays a modal bottom sheet containing an `InAppWebView`. This web view loads a predefined URL to the age verification page, complete with query parameters that customize the verification experience (e.g., session UUID, website ID, language, theme).

5. **Handle Verification Results**: The web view setup includes a JavaScript handler named `verification-result`. This handler listens for post-verification messages from the web content, extracting and processing the verification result. Depending on the outcome (verified or not verified), the app updates the verification status displayed on the home page.

6. **Process Verification Signature**: An additional security layer is added by verifying a digital signature associated with the verification result. This ensures the integrity and authenticity of the verification process, safeguarding against tampering or spoofing.

This overview outlines the steps and components involved in integrating an age verification system into a Flutter application, leveraging web view and secure communication to ensure a user-friendly and secure verification process.
