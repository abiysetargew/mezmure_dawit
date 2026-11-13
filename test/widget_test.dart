import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mezmure_dawit/main.dart';
import 'package:mezmure_dawit/psalm_data.dart';

void main() {
  group('AppSettings smoke tests', () {
    test('isDarkMode defaults to true', () {
      expect(AppSettings.isDarkMode.value, true);
    });

    test('fontSize defaults to 20.0', () {
      expect(AppSettings.fontSize.value, 20.0);
    });

    test('favoriteIds defaults to empty set', () {
      expect(AppSettings.favoriteIds.value, isEmpty);
    });
  });

  group('Verse model tests', () {
    test('Verse.fromJson parses standard keys', () {
      final v = Verse.fromJson({
        'number': 1,
        'amharic': 'እግዚአብሔር',
        'geez': 'እግዚአብሔር',
        'english': 'God',
      });
      expect(v.number, 1);
      expect(v.amharic, 'እግዚአብሔር');
      expect(v.geez, 'እግዚአብሔር');
      expect(v.english, 'God');
    });

    test('Verse.fromJson handles short keys', () {
      final v = Verse.fromJson({
        'n': 2,
        'am': 'ሰላም',
        'ge': 'ሰላም',
        'en': 'Peace',
      });
      expect(v.number, 2);
      expect(v.amharic, 'ሰላም');
      expect(v.geez, 'ሰላም');
      expect(v.english, 'Peace');
    });

    test('Verse.fromJson falls back to empty strings for missing fields', () {
      final v = Verse.fromJson({});
      expect(v.amharic, '');
      expect(v.geez, '');
      expect(v.english, '');
      expect(v.number, 0);
    });
  });

  group('Psalm model tests', () {
    test('Psalm.fromJson parses all fields', () {
      final p = Psalm.fromJson({
        'id': 23,
        'title': 'መዝሙር ፳፫',
        'day': 'ሰኞ (Monday)',
        'tags': ['Morning', 'Shepherd'],
        'verses': [
          {'n': 1, 'am': 'እግዚአብሔር', 'ge': 'እግዚአብሔር', 'en': 'The Lord'}
        ],
      });
      expect(p.number, 23);
      expect(p.titleAmharic, 'መዝሙር ፳፫');
      expect(p.day, 'ሰኞ (Monday)');
      expect(p.tags, ['Morning', 'Shepherd']);
      expect(p.verses.length, 1);
      expect(p.verses.first.amharic, 'እግዚአብሔር');
    });

    test('Psalm.fromJson handles alternate keys', () {
      final p = Psalm.fromJson({
        'number': 5,
        'titleAmharic': 'Psalm Five',
        'day': 'Thursday',
        'tags': [],
        'verses': [],
      });
      expect(p.number, 5);
      expect(p.titleAmharic, 'Psalm Five');
    });

    test('Psalm.fromJson defaults title and day', () {
      final p = Psalm.fromJson({'id': 1, 'verses': []});
      expect(p.titleAmharic, 'መዝሙር');
      expect(p.day, '');
      expect(p.tags, isEmpty);
    });
  });

  group('PsalmRepository tests', () {
    test('daysOfWeek has 7 entries', () {
      expect(PsalmRepository.daysOfWeek.length, 7);
    });

    test('getPsalmsByDay returns empty when not loaded', () {
      final results = PsalmRepository.getPsalmsByDay('ሰኞ (Monday)');
      expect(results, isA<List<Psalm>>());
    });

    test('getPsalmsByTag returns list', () {
      expect(PsalmRepository.getPsalmsByTag('Morning'), isA<List<Psalm>>());
    });
  });

  group('ListX extension tests', () {
    test('firstOrNull returns null on empty list', () {
      final list = <int>[];
      expect(list.firstOrNull, isNull);
    });

    test('firstOrNull returns first element', () {
      final list = [1, 2, 3];
      expect(list.firstOrNull, 1);
    });
  });

  group('Widget smoke tests', () {
    testWidgets('MezmureDawitApp renders without error',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MezmureDawitApp());
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('SacredMainScaffold shows all 4 navigation destinations',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MezmureDawitApp());
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Index"), findsOneWidget);
      expect(find.text("Favorites"), findsOneWidget);
      expect(find.text("Settings"), findsOneWidget);
    });

    testWidgets('SacredMainScaffold navigation changes page',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MezmureDawitApp());
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.text("Index"));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text("Psalm Index"), findsOneWidget);
    });

    testWidgets('DivineSettings shows About option',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MezmureDawitApp());
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.text("Settings"));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text("About Mezmure Dawit"), findsOneWidget);
    });

    testWidgets('SacredAbout page shows app name', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SacredAbout(),
      ));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text("መዝሙረ ዳዊት"), findsOneWidget);
      expect(find.text("Mezmure Dawit"), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text("Version 1.0.8"), findsOneWidget);
    });
  });
}
