import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exp 8', // Updated app title
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
        drawerTheme: const DrawerThemeData(backgroundColor: Colors.grey),
      ),
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    DashboardPage(),
    ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openAboutPage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AboutPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exp 8'), // Updated AppBar title
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Exp 8', // Updated Drawer header
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text('About', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _openAboutPage(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Logged out!')));
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            IconData icon;
            String label;
            switch (index) {
              case 0:
                icon = Icons.home;
                label = 'Home';
                break;
              case 1:
                icon = Icons.dashboard;
                label = 'Dashboard';
                break;
              default:
                icon = Icons.person;
                label = 'Profile';
            }
            bool selected = _selectedIndex == index;

            return GestureDetector(
              onTap: () => _onTabTapped(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? Colors.deepPurple : Colors.grey[800],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(icon, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.deepPurple : Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

// Simple pages
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Home Page',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Dashboard Page',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profile Page',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Center(
        child: Text(
          'This is the About Page',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
