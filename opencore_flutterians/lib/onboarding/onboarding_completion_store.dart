abstract class OnboardingCompletionStore {
  Future<bool> hasCompleted();
  Future<void> markCompleted();
}
