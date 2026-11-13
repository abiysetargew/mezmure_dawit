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
    } catch (_) {
      allPsalms = [];
    }
    _generateMissingData();
    isLoaded = true;
  }

  static void _generateMissingData() {
    List<Psalm> fullList = [];
    for (int i = 1; i <= 150; i++) {
      Psalm? existing = allPsalms.where((p) => p.number == i).firstOrNull;
      if (existing != null) {
        fullList.add(existing);
      } else {
        String day = daysOfWeek[(i - 1) % 7];
        List<String> tags = (i <= 30)
            ? ["Morning"]
            : (i <= 100)
                ? ["Daylight"]
                : ["Evening"];
        fullList.add(Psalm(
          number: i,
          titleAmharic: "መዝሙር $i",
          day: day,
          tags: tags + ["Praise"],
          verses: _getTestContent(i),
        ));
      }
    }
    allPsalms = fullList;
    allPsalms.sort((a, b) => a.number.compareTo(b.number));
  }

  static List<Verse> _getTestContent(int id) {
    if (id == 2) {
      return [
        Verse(
            number: 1,
            amharic: "አሕዛብ ለምን አጉረመረሙ? ወገኖችስ ለምን ከንቱ ነገርን አሰቡ?",
            geez: "ለምንቱ አንጐርጐሩ አሕዛብ ወሕዝብኒ ነበቡ ከንቶ።",
            english: "Why do the heathen rage?"),
        Verse(
            number: 2,
            amharic: "የምድር ነገሥታት ተነሡ፥ አለቆችም በእግዚአብሔርና በመሲሑ ላይ እንዲህ ሲሉ ተማከሩ።",
            geez: "ተንሥኡ ነገሥተ ምድር ወመኳንንትኒ ተጋብኡ ምስሌሆሙ።",
            english: "The kings of the earth set themselves."),
        Verse(
            number: 3,
            amharic: "ማሰሪያቸውን እንበጥስ፥ ቀንበራቸውንም ከእኛ እንጣል።",
            geez: "ንበትክ ማእሠሪሆሙ፤ ወንገድፍ እምላዕሌነ አርዑቶሙ።",
            english: "Let us break their bands asunder."),
        Verse(
            number: 4,
            amharic: "በሰማይ የሚኖር እርሱ ይሥቃል፥ ጌታም ይሣለቅባቸዋል።",
            geez: "ዘይነብር ውስተ ሰማያት ይሥሕቆሙ፤ ወእግዚአብሔር ይሣለቅ ላዕሌሆሙ።",
            english: "He that sitteth in the heavens shall laugh."),
        Verse(
            number: 5,
            amharic: "በዚያን ጊዜ በቍጣው ይናገራቸዋል፥ በመዓቱም ያውካቸዋል።",
            geez: "ይቤሎሙ በውእቱ መዋዕል በቍጣሁ፤ ወያደነግፆሙ በመዓቱ።",
            english: "Then shall he speak unto them in his wrath."),
        Verse(
            number: 6,
            amharic: "እኔ ግን ንጉሤን ቀባሁ በቅዱስ ተራራዬ በጽዮን ላይ።",
            geez: "አንሰ ተሠየምኩ ንጉሠ በጽዮን በደብረ መቅደሱ።",
            english: "Yet have I set my king upon my holy hill of Zion."),
        Verse(
            number: 7,
            amharic: "ትእዛዙን እናገራለሁ፤ እግዚአብሔር አለኝ፦ አንተ ልጄ ነህ፥ እኔ ዛሬ ወለድሁህ።",
            geez: "እነግር ትእዛዞ ለእግዚአብሔር፤ እግዚአብሔር ይቤለኒ ወልድየ አንተ ወአነ ዮም ወለድኩከ።",
            english: "I will declare the decree: Thou art my Son."),
        Verse(
            number: 8,
            amharic: "ለምነኝ፥ አሕዛብን ለርስትህ የምድርንም ዳርቻ ለግዛትህ እሰጥሃለሁ።",
            geez: "ስአለኒ ወእሁበከ አሕዛበ ለርስትከ፤ ወለአዝማደ ምድር ለግዛትከ።",
            english: "Ask of me, and I shall give thee the heathen."),
        Verse(
            number: 9,
            amharic: "በብረት በትር ትጠብቃቸዋለህ፥ እንደ ሸክላ ሠሪ ዕቃ ትቀጠቅጣቸዋለህ።",
            geez: "ትርዕዮሙ በበትረ ኀጺን፤ ወከመ ንዋየ ሸክላ ትቀጠቅጦሙ።",
            english: "Thou shalt break them with a rod of iron."),
        Verse(
            number: 10,
            amharic: "አሁንም እናንተ ነገሥታት፥ አስተውሉ፤ የምድር ፈራጆችም፥ ተገሠጹ።",
            geez: "ወይእዜኒ ነገሥት አእምሩ፤ ወተገሠጹ ኵሎሙ ፈራጅያነ ምድር።",
            english: "Be wise now therefore, O ye kings."),
        Verse(
            number: 11,
            amharic: "ለእግዚአብሔር በፍርሃት ተገዙ፥ በረዓድም ደስ ይበላችሁ።",
            geez: "ተቀነዩ ለእግዚአብሔር በፍርሃት፤ ወተሐሠዩ ሎቱ በረዓድ።",
            english: "Serve the Lord with fear."),
        Verse(
            number: 12,
            amharic:
                "ተቈጥቶ ከመንገድ እንዳትጠፉ ልጁን ሳሙት፥ ቍጣው ፈጥና ትነድዳለችና። በእርሱ የሚታመኑ ሁሉ ምስጉኖች ናቸው።",
            geez: "አጽንዕዋ ለጥበብ ከመ ኢይትመዓዕ እግዚአብሔር።",
            english: "Kiss the Son, lest he be angry."),
      ];
    }
    return [
      Verse(
          number: 1,
          amharic: "እግዚአብሔር እረኛዬ ነው፥ የሚያሳጣኝም የለም።",
          geez: "እግዚአብሔር ይርዕየኒ ወአልቦ ዘይኅፅነኒ።",
          english: "The Lord is my shepherd.")
    ];
  }

  static List<Psalm> getPsalmsByDay(String day) =>
      allPsalms.where((p) => p.day == day).toList();
  static List<Psalm> getPsalmsByTag(String tag) =>
      allPsalms.where((p) => p.tags.contains(tag)).toList();
}

extension ListX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
