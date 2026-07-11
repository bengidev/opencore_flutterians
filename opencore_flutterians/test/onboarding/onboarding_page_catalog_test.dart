import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/onboarding_page_catalog.dart';
import 'package:opencore_flutterians/onboarding/onboarding_page_model.dart';

void main() {
  test('catalog has 4 feature pages then 1 cta', () {
    final pages = OnboardingPageCatalog.build();
    expect(pages, hasLength(5));
    expect(pages.take(4).every((p) => p.kind == OnboardingPageKind.feature), isTrue);
    expect(pages.last.kind, OnboardingPageKind.cta);
    expect(pages[0].headline, contains('encrypted'));
    expect(pages.last.headline, 'OpenCore');
    expect(pages.map((p) => p.heroId).toSet(), hasLength(5));
  });
}
