import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:opencore_flutterians/core/open_core_bloc_observer.dart';
import 'package:opencore_flutterians/onboarding/onboarding.dart';
import 'package:opencore_flutterians/onboarding/onboarding_theme.dart';
import 'package:opencore_flutterians/onboarding/widgets/onboarding_tactile_button.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const OpenCoreBlocObserver();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationDocumentsDirectory()).path,
          ),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const OpenCoreApp());
}

class OpenCoreApp extends StatelessWidget {
  const OpenCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenCore',
      theme: OnboardingTheme.light(),
      darkTheme: OnboardingTheme.dark(),
      themeMode: ThemeMode.system,
      home: OnboardingFacade().buildRoot(
        home: const OpenCoreHomePage(title: 'OpenCore'),
      ),
    );
  }
}

class OpenCoreHomePage extends StatefulWidget {
  const OpenCoreHomePage({super.key, required this.title});

  final String title;

  @override
  State<OpenCoreHomePage> createState() => _OpenCoreHomePageState();
}

class _OpenCoreHomePageState extends State<OpenCoreHomePage> {
  int _counter = 0;

  void _incrementCounter() => setState(() => _counter++);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title, style: theme.textTheme.headlineMedium),
              const Spacer(),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'You have pushed the button this many times:',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text('$_counter', style: theme.textTheme.displayLarge),
                  ],
                ),
              ),
              const Spacer(),
              OnboardingFilledButton(
                onPressed: _incrementCounter,
                child: const Text('INCREMENT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
