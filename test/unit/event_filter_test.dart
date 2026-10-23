import 'package:flutter_test/flutter_test.dart';
import 'package:rzl_app/features/events/domain/event_filter.dart';

void main() {
  group('EventFilter', () {
    test('two filters with the same values are equal', () {
      // This matters: the filter is the argument to a Riverpod family, so value
      // equality is what makes provider caching work.
      const a = EventFilter(municipalityId: 'muni-1');
      const b = EventFilter(municipalityId: 'muni-1');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different municipalities are not equal', () {
      const a = EventFilter(municipalityId: 'muni-1');
      const b = EventFilter(municipalityId: 'muni-2');

      expect(a, isNot(equals(b)));
    });

    test('isActive reflects whether any filter is set', () {
      expect(const EventFilter().isActive, isFalse);
      expect(const EventFilter(categorySlug: 'festival').isActive, isTrue);
    });

    test('copyWith can clear a value explicitly', () {
      const filter = EventFilter(municipalityId: 'muni-1');

      expect(filter.copyWith(clearMunicipality: true).municipalityId, isNull);
      expect(
        filter.copyWith().municipalityId,
        'muni-1',
        reason: 'copyWith without arguments must preserve the value',
      );
    });
  });
}
