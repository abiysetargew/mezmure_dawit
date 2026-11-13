import 'dart:convert';
import 'package:flutter/services.dart';

class Verse {
  final int number;
  final String amharic;
  final String geez;
  final String english;

  Verse(
      {required this.number,
      required this.amharic,
      required this.geez,
      required this.english});

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      number: json['n'] ?? json['number'] ?? 0,
      amharic: json['am'] ?? json['amharic'] ?? "",
      geez: json['ge'] ?? json['geez'] ?? "",
      english: json['en'] ?? json['english'] ?? "",
    );
  }
}

class Psalm {
  final int number;
  final String titleAmharic;
  final String day;
  final List<Verse> verses;
  final List<String> tags;

  Psalm(
      {required this.number,
      required this.titleAmharic,
      required this.day,
      required this.verses,
      required this.tags});

  factory Psalm.fromJson(Map<String, dynamic> json) {
    var list = json['verses'] as List? ?? [];
    List<Verse> versesList = list.map((i) => Verse.fromJson(i)).toList();
    return Psalm(
      number: json['id'] ?? json['number'] ?? 0,
      titleAmharic: json['title'] ?? json['titleAmharic'] ?? "መዝሙር",
      day: json['day'] ?? "",
      tags: List<String>.from(json['tags'] ?? []),
      verses: versesList,
    );
  }
}

class PsalmRepository {
  static List<Psalm> allPsalms = [];
  static bool isLoaded = false;
  static Object? loadError;

  static const List<String> daysOfWeek = [
    "እሑድ (Sunday)",
    "ሰኞ (Monday)",
    "ማክሰኞ (Tuesday)",
    "ረቡዕ (Wednesday)",
    "ሐሙስ (Thursday)",
    "ዓርብ (Friday)",
    "ቅዳሜ (Saturday)"
  ];

  static Future<void> loadPsalms() async {
    if (isLoaded) return;
    try {
      final String response = await rootBundle.loadString('assets/psalms.json');
      final data = await json.decode(response);
      allPsalms = (data as List).map((i) => Psalm.fromJson(i)).toList();
      allPsalms.sort((a, b) => a.number.compareTo(b.number));
      loadError = null;
    } catch (e) {
      // Do not fabricate content — surface the failure instead.
      allPsalms = [];
      loadError = e;
    }
    isLoaded = true;
  }

  static int get totalVerses =>
      allPsalms.fold(0, (sum, p) => sum + p.verses.length);

  static String formatCount(int n) =>
      n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');

  static List<Psalm> getPsalmsByDay(String day) =>
      allPsalms.where((p) => p.day == day).toList();
  static List<Psalm> getPsalmsByTag(String tag) =>
      allPsalms.where((p) => p.tags.contains(tag)).toList();
}

extension ListX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
