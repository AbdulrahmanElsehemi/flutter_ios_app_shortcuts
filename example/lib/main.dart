import 'package:flutter/material.dart';
import 'package:flutter_ios_app_shortcuts/flutter_ios_app_shortcuts.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Configure the plugin.
  await AppShortcutService.instance.initialize(
    config: AppShortcutConfig(
      navigatorKey: navigatorKey,
      baseRoute: '/home',
      routeMap: {
        'search': '/search',
        'profile': '/profile',
      },
    ),
  );

  // 2. Read any cold-start shortcut BEFORE runApp so the initial route is right.
  await AppShortcutService.instance.captureInitialShortcut();

  runApp(const MyApp());

  // 3. Start listening for warm-start shortcuts AFTER runApp.
  AppShortcutService.instance.startListening();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 4. Navigate to the shortcut target after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppShortcutService.instance.handleInitialShortcut();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Skip onboarding/splash if a shortcut cold-started the app.
    final initialRoute = AppShortcutService.instance.hasShortcutLaunch
        ? '/home'
        : '/onboarding';

    return MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => const HomeScreen(),
        '/search': (_) => const SearchScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
    );
  }

  @override
  void dispose() {
    AppShortcutService.instance.dispose();
    super.dispose();
  }
}

// ── Screens ──────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          child: const Text('Go to Home'),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/search'),
              child: const Text('Go to Search'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              child: const Text('Go to Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const Center(child: Text('Search Screen')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Screen')),
    );
  }
}
