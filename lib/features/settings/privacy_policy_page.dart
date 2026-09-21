import 'package:flutter/material.dart';
import 'package:talevra/app/theme/app_theme.dart';
import 'package:talevra/l10n/app_localizations.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyPage extends StatefulWidget {
  static final uri = Uri.parse('https://talevra.cc/privacy.html');

  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  late final WebViewController _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
        ),
      )
      ..loadRequest(PrivacyPolicyPage.uri);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l.privacyPolicy),
        backgroundColor: Colors.white,
        foregroundColor: AppPalette.ink,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_progress < 100)
            LinearProgressIndicator(
              value: _progress == 0 ? null : _progress / 100,
              color: AppPalette.pink,
              minHeight: 2,
            ),
        ],
      ),
    );
  }
}
