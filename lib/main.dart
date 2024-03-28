import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final browser = ChromeSafariBrowser();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final httpsUri = Uri(
        scheme: 'https',
        host: 'authenticator-dev.opale.io',
        queryParameters: {
          "OPALE_SESSION_UUID": "Current user or session UID",
          "OPALE_WEBSITE_ID": "Your API key",
          "OPALE_LANGUAGE": "en", // || French “fr” || Italian “it”
          "OPALE_THEME": "light", // || “dark”
          "OPALE_PRIMARY_COLOR": "#D1016E", // Determine color scheme
          "OPALE_MODE": "webview" // Resizes certain elements
        });
    late final String urlString = httpsUri.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opale Flutter Demo'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              await browser.open(
                  url: WebUri(urlString),
                  settings: ChromeSafariBrowserSettings(
                      shareState: CustomTabsShareState.SHARE_STATE_OFF,
                      barCollapsingEnabled: true));
            },
            child: const Text("start verification")),
      ),
    );
  }
}
