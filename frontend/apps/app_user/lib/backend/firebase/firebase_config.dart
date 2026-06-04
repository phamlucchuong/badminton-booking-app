import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (error) {
    debugPrint(
      'Firebase initialization skipped. Add platform Firebase config files to enable live data. Error: $error',
    );
  }
}
