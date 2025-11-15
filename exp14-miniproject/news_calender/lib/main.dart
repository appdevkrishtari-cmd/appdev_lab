import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const NewsCalendarApp());
}

class NewsCalendarApp extends StatefulWidget {
  const NewsCalendarApp({super.key});
  @override
  State<NewsCalendarApp> createState() => _NewsCalendarAppState();
}

class _NewsCalendarAppState extends State<NewsCalendarApp> {
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    // Ensure anonymous sign-in for guest behavior
    _auth.ensureAnonymous();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News Calendar',
      theme: ThemeData.dark().copyWith(
        useMaterial3: false,
        colorScheme: ColorScheme.dark(),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginOrHomeGate(),
    );
  }
}

/// Shows Login page briefly but allows guest; auth flow is simple:
class LoginOrHomeGate extends StatelessWidget {
  const LoginOrHomeGate({super.key});

  @override
  Widget build(BuildContext context) {
    // For simplicity: open LoginPage which contains a "Continue as Guest" button.
    return const LoginPage();
  }
}
