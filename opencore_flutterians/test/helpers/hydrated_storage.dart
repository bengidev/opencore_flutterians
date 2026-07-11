import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockHydratedStorage extends Mock implements Storage {}

/// Installs an in-memory mock [HydratedBloc.storage] for tests.
void setUpHydratedStorage() {
  final storage = MockHydratedStorage();
  when(() => storage.write(any(), any())).thenAnswer((_) async {});
  when(() => storage.read(any())).thenReturn(null);
  when(() => storage.delete(any())).thenAnswer((_) async {});
  when(() => storage.clear()).thenAnswer((_) async {});
  HydratedBloc.storage = storage;
}
