import 'package:flutter/material.dart';
import '../widgets/custom_calendar.dart';
import '../widgets/day_details_sheet.dart';
import '../services/news_service.dart';
import '../services/auth_service.dart';
import 'vip_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NewsService _newsService = NewsService();
  final AuthService _auth = AuthService();

  String provider = 'Inshorts';
  DateTime selected = DateTime.now();

  void _onDayTap(DateTime d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DayDetailsSheet(date: d, initialProvider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Calendar'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (p) {
              setState(() => provider = p);
            },
            itemBuilder: (_) => _newsService.providers.keys
                .map((p) => PopupMenuItem(value: p, child: Text(p)))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(children: [
                Text(provider),
                const Icon(Icons.arrow_drop_down)
              ]),
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_auth.currentUser?.email ?? 'Guest',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                    _auth.currentUser == null ? 'Guest (anonymous)' : 'Logged'),
              ],
            )),
            ListTile(
              leading: const Icon(Icons.upgrade),
              title: const Text('VIP'),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const VipPage())),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login / Register'),
              onTap: () => Navigator.pushNamed(context, '/login'),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () async {
                await _auth.signOut();
                setState(() {});
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: CustomCalendar(
                initialSelected: selected,
                onDayTap: (d) {
                  setState(() => selected = d);
                  _onDayTap(d);
                }),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 1,
            child: Center(
                child: Text(
                    'Latest news / Today (provider: $provider) — Tap a date for day-specific news')),
          ),
        ],
      ),
    );
  }
}
