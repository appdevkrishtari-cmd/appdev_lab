import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;
  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyCcbxrNP6nCxnxRuPLI4D87D_ZcYTnWgKc",
      authDomain: "newscalender-e2e3f.firebaseapp.com",
      projectId: "newscalender-e2e3f",
      storageBucket: "newscalender-e2e3f.firebasestorage.app",
      messagingSenderId: "835775504194",
      appId: "1:835775504194:web:0df897f1f6123da980b2db",
      measurementId: "G-4RYY6DBTM1");
}
