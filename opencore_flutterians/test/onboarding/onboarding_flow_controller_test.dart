import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/onboarding_completion_store.dart';
import 'package:opencore_flutterians/onboarding/onboarding_flow_controller.dart';
import 'package:opencore_flutterians/onboarding/onboarding_page_catalog.dart';

class _FakeStore implements OnboardingCompletionStore {
  bool completed = false;
  bool throwOnMark = false;

  @override
  Future<bool> hasCompleted() async => completed;

  @override
  Future<void> markCompleted() async {
    if (throwOnMark) throw StateError('write failed');
    completed = true;
  }
}

void main() {
  late _FakeStore store;
  late OnboardingFlowController controller;
  var completedCalls = 0;

  setUp(() {
    store = _FakeStore();
    completedCalls = 0;
    controller = OnboardingFlowController(
      pages: OnboardingPageCatalog.build(),
      store: store,
      onCompleted: () => completedCalls++,
    );
  });

  tearDown(() => controller.dispose());

  test('starts at index 0', () {
    expect(controller.index, 0);
    expect(controller.isFirst, isTrue);
    expect(controller.isCta, isFalse);
  });

  test('next advances and clamps at cta', () {
    controller.next();
    expect(controller.index, 1);
    for (var i = 0; i < 10; i++) {
      controller.next();
    }
    expect(controller.index, 4);
    expect(controller.isCta, isTrue);
  });

  test('back retreats and clamps at 0', () {
    controller.next();
    controller.back();
    expect(controller.index, 0);
    controller.back();
    expect(controller.index, 0);
  });

  test('skip jumps to cta without persisting', () async {
    controller.skip();
    expect(controller.index, 4);
    expect(await store.hasCompleted(), isFalse);
    expect(completedCalls, 0);
  });

  test('enter persists and invokes onCompleted', () async {
    controller.skip();
    await controller.enter();
    expect(store.completed, isTrue);
    expect(completedCalls, 1);
    expect(controller.enterError, isNull);
  });

  test('enter failure sets inline error and does not complete', () async {
    store.throwOnMark = true;
    controller.skip();
    await controller.enter();
    expect(completedCalls, 0);
    expect(controller.enterError, '[ERROR: COULD NOT SAVE]');
  });
}
