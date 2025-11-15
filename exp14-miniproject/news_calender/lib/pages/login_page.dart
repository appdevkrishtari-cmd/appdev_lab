import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  bool loading = false;

  Future<void> _guest() async {
    setState(() => loading = true);
    await _auth.ensureAnonymous();
    setState(() => loading = false);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomePage()));
  }

  Future<void> _register() async {
    setState(() => loading = true);
    try {
      await _auth.signUpWithEmail(emailCtrl.text.trim(), passCtrl.text);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomePage()));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Register failed: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _login() async {
    setState(() => loading = true);
    try {
      await _auth.signInWithEmail(emailCtrl.text.trim(), passCtrl.text);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomePage()));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Guest')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email')),
                  TextField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password')),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _login, child: const Text('Login')),
                  ElevatedButton(
                      onPressed: _register, child: const Text('Register')),
                  const SizedBox(height: 12),
                  ElevatedButton(
                      onPressed: _guest,
                      child: const Text('Continue as Guest')),
                ],
              ),
      ),
    );
  }
}
