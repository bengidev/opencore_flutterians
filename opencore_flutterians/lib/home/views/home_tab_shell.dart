import 'package:flutter/material.dart';
import '../home_theme.dart';
import 'home_placeholder_page.dart';

class HomeTabShell extends StatefulWidget {
  const HomeTabShell({super.key});

  @override
  State<HomeTabShell> createState() => _HomeTabShellState();
}

class _HomeTabShellState extends State<HomeTabShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final colors = HomeColors.of(context);
    final pages = const [
      ColoredBox(color: Colors.white, child: SizedBox.expand()),
      HomePlaceholderPage(title: 'Settings'),
      HomePlaceholderPage(title: 'About'),
    ];

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => setState(() => _index = 0),
              child: const Text('Home'),
            ),
            TextButton(
              onPressed: () => setState(() => _index = 1),
              child: const Text('Settings'),
            ),
            TextButton(
              onPressed: () => setState(() => _index = 2),
              child: const Text('About'),
            ),
          ],
        ),
      ),
    );
  }
}
