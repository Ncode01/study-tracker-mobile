import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:study/src/features/stats/providers/stats_provider.dart';
import 'package:study/src/services/database_helper.dart';

import '../../../mocks/mock_database_helper.mocks.dart';

void main() {
  group('StatsProvider', () {
    late StatsProvider provider;
    late MockDatabaseHelper mockDb;

    setUp(() {
      mockDb = MockDatabaseHelper();
      provider = StatsProvider(dbHelper: mockDb);
    });

    test('fetchStatsData calls DB and updates state', () async {
      when(
        mockDb.getAggregatedTimePerDay(any, any),
      ).thenAnswer((_) async => {'2025-05-20': 60});
      when(
        mockDb.getAggregatedTimePerProject(any, any),
      ).thenAnswer((_) async => {'Test Project': 60});
      await provider.fetchStatsData();
      expect(provider.timePerDay['2025-05-20'], 60);
      expect(provider.timePerProject['Test Project'], 60);
    });

    test('setSelectedPeriod updates range and calls fetchStatsData', () async {
      var called = false;
      provider.fetchStatsData = () async {
        called = true;
      };
      provider.setSelectedPeriod(StatsPeriod.Month);
      expect(provider.selectedPeriod, StatsPeriod.Month);
      expect(called, true);
    });
  });
}
