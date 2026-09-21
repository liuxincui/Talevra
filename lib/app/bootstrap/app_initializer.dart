import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:talevra/core/firebase/firebase_services.dart';
import 'package:talevra/core/logger/app_logger.dart';
import 'package:talevra/core/network/api_client.dart';
import 'package:talevra/core/storage/local_storage.dart';

final localeOverrideNotifier = ValueNotifier<Locale?>(null);

class AppInitializer {
  const AppInitializer._();

  static Future<void>? _initialization;

  static Future<void> init() => _initialization ??= _init();

  static Future<void> _init() async {
    ApiClient.init();
    await LocalStorage.init();

    final code = LocalStorage.I.getString('settings.locale');
    localeOverrideNotifier.value = code == null ? null : Locale(code);

    // Firebase and notification permission may involve platform services or
    // the network. They must never hold the user on the splash screen.
    unawaited(_initFirebase());
  }

  static Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp();
      await FirebaseServices.init();
    } catch (error, stack) {
      AppLogger.e(
        'Firebase initialization skipped',
        error: error,
        stack: stack,
        tag: 'Firebase',
      );
    }
  }
}
