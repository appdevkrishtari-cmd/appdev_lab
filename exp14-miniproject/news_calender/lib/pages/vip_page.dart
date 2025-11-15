import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class VipPage extends StatefulWidget {
  const VipPage({super.key});
  @override
  State<VipPage> createState() => _VipPageState();
}

class _VipPageState extends State<VipPage> {
  final AuthService _auth = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool isVIP = false;
  bool loading = false;

  Future<void> _load() async {
    final u = _auth.currentUser;
    if (u == null) return;
    final doc = await _db.collection('users').doc(u.uid).get();
    setState(() => isVIP = doc.data()?['isVIP'] == true);
  }

  Future<void> _toggle() async {
    final u = _auth.currentUser;
    if (u == null) return;
    setState(() => loading = true);
    await _db
        .collection('users')
        .doc(u.uid)
        .set({'isVIP': !isVIP}, SetOptions(merge: true));
    await _load();
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VIP')),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isVIP ? 'You are VIP' : 'You are not VIP'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                      onPressed: _toggle,
                      child: Text(isVIP ? 'Revoke VIP' : 'Become VIP (mock)')),
                ],
              ),
      ),
    );
  }
}
