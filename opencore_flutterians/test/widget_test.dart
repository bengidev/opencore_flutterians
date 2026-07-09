import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first launch shows onboarding continue', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const OpenCoreApp());
    await tester.pumpAndSettle();
    expect(find.text('CONTINUE'), findsOneWidget);
  });

  testWidgets('completed launch shows home counter', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding.completed': true});
    await tester.pumpWidget(const OpenCoreApp());
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });
}
