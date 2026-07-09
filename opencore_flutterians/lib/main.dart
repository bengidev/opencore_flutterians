import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opencore_flutterians/onboarding/onboarding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const _OpenCoreRoot(),
    );
  }
}

class _OpenCoreRoot extends StatefulWidget {
  const _OpenCoreRoot();

  @override
  State<_OpenCoreRoot> createState() => _OpenCoreRootState();
}

class _OpenCoreRootState extends State<_OpenCoreRoot> {
  late final Future<Widget> _rootFuture =
      OnboardingFacade().buildRoot(home: const OpenCoreHomePage(title: 'OpenCore'));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _rootFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('[LOADING...]')),
          );
        }
        return snapshot.data!;
      },
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
