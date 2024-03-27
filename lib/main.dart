import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:crypto/crypto.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera
      .request(); // Ensure necessary permissions are requested
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

// HomePage widget to display verification status and trigger verification
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String verificationStatus = "Not yet verified"; // Verification status message

  // Function to update verification status and refresh UI
  void updateVerificationStatus(String newStatus) {
    setState(() {
      verificationStatus = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Opale Flutter Demo")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(verificationStatus),
            ElevatedButton(
              onPressed: () =>
                  showVerificationPopup(context), // Trigger verification
              child: const Text("Start Verification"),
            ),
          ],
        ),
      ),
    );
  }

  void showVerificationPopup(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true, // Allow the modal to take up full screen
        builder: (BuildContext bc) {
          return FractionallySizedBox(
            heightFactor: 0.9, // Modal height factor
            child: InAppWebViewPage(
              // Scrolling required for verification iFrames
              onVerificationComplete: (String result) {
                updateVerificationStatus(
                    result); // Update status based on verification result
                Navigator.pop(context); // Close the modal upon completion
              },
            ),
          );
        });
  }
}

// InAppWebViewPage widget to handle the web view and verification logic
class InAppWebViewPage extends StatelessWidget {
  final Function(String)
      onVerificationComplete; // Callback to update verification status

  InAppWebViewPage({super.key, required this.onVerificationComplete});

  final String signingSecret = "Your Signing Secret";
  final httpsUri =
      Uri(scheme: 'https', host: 'authenticator.opale.io', queryParameters: {
    "OPALE_SESSION_UUID": "Current user or session UID",
    "OPALE_WEBSITE_ID": "Your API key",
    "OPALE_LANGUAGE": "en", // || French “fr” || Italian “it”
    "OPALE_THEME": "light", // || “dark”
    "OPALE_PRIMARY_COLOR": "#D1016E", // Determine color scheme
    "OPALE_MODE": "webview" // Ensures iFrames are sized correctly
  });

  late final String urlString = httpsUri.toString();

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(urlString)),
      onWebViewCreated: (InAppWebViewController controller) {
        // Setup controller and add JavaScript handler for verification result
        controller.addJavaScriptHandler(
          handlerName: 'verification-result',
          callback: (verificationResult) async {
            checkVerificationResult(verificationResult);
          },
        );
      },
      onPermissionRequest:
          (InAppWebViewController controller, PermissionRequest origin) async {
        return PermissionResponse(
          action: PermissionResponseAction.GRANT,
          resources: [
            PermissionResourceType.CAMERA,
          ],
        );
      },
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      },
    );
  }

  Future<void> checkVerificationResult(verificationResult) async {
    final resultData = verificationResult[0] as Map<String, dynamic>;
    final String user = resultData['user'];
    final String timestamp = resultData['timestamp'];
    final String result = resultData['result'];
    final String signature = resultData['signature'];

    if (result != 'ok') {
      onVerificationComplete('VERIFICATION FAILED');
      return;
    }

    final calculatedSignature =
        await calculateSignature(user, timestamp, result, signingSecret);
    if (calculatedSignature == signature) {
      onVerificationComplete('ACCESS SECURED');
    } else {
      onVerificationComplete('SIGNATURE MISMATCH');
    }
  }

  Future<String> calculateSignature(String user, String timestamp,
      String result, String signingSecret) async {
    final data = '$user.$timestamp.$result';
    final key = utf8.encode(signingSecret);
    final bytes = utf8.encode(data);

    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);

    return digest.toString();
  }
}
