import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'psalm_data.dart';
import 'ad_service.dart';
import 'ad_banner_widget.dart';
import 'app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AdService.initialize();
  } catch (_) {}
  await AppSettings.load();
  await PsalmRepository.loadPsalms();
  runApp(const MezmureDawitApp());
}

class AppSettings {
  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(true);
  static final ValueNotifier<double> fontSize = ValueNotifier<double>(20.0);
  static final ValueNotifier<Set<int>> favoriteIds =
      ValueNotifier<Set<int>>({});

  static SharedPreferences? _prefs;

  static Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    isDarkMode.value = _prefs?.getBool('darkMode') ?? true;
    fontSize.value = _prefs?.getDouble('fontSize') ?? 20.0;
    final saved = _prefs?.getStringList('favorites') ?? [];
    favoriteIds.value = saved.map((e) => int.parse(e)).toSet();

    isDarkMode.addListener(_saveDarkMode);
    fontSize.addListener(_saveFontSize);
    favoriteIds.addListener(_saveFavorites);
  }

  static void _saveDarkMode() {
    _prefs?.setBool('darkMode', isDarkMode.value);
  }

  static void _saveFontSize() {
    _prefs?.setDouble('fontSize', fontSize.value);
  }

  static void _saveFavorites() {
    _prefs?.setStringList(
        'favorites', favoriteIds.value.map((e) => e.toString()).toList());
  }
}

class MezmureDawitApp extends StatelessWidget {
  const MezmureDawitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppSettings.isDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'መዝሙረ ዳዊት',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const SacredMainScaffold(),
        );
      },
    );
  }
}

class SacredMainScaffold extends StatefulWidget {
  const SacredMainScaffold({super.key});
  @override
  State<SacredMainScaffold> createState() => _SacredMainScaffoldState();
}

class _SacredMainScaffoldState extends State<SacredMainScaffold>
    with SingleTickerProviderStateMixin {
  int _idx = 0;
  int _homeTapCount = 0;
  late AnimationController _navController;

  @override
  void initState() {
    super.initState();
    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  void _onNavTap(int i) {
    if (_idx == 0 && i != 0) {
      _homeTapCount++;
      if (_homeTapCount >= 3) {
        _homeTapCount = 0;
        try {
          AdService.showInterstitial();
        } catch (_) {}
      }
    }
    setState(() => _idx = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.03, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.97, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          ),
        ),
        child: KeyedSubtree(key: ValueKey(_idx), child: _pages[_idx]),
      ),
      bottomNavigationBar: _AnimatedNavBar(
        selectedIndex: _idx,
        onDestinationSelected: _onNavTap,
      ),
    );
  }

  static final List<Widget> _pages = [
    const SanctuaryHome(),
    const LibrarySearchHub(),
    const FavoritesSanctuary(),
    const DivineSettings(),
  ];
}

class _AnimatedNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _AnimatedNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141218) : Colors.white,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          _NavDestination(
            "Home",
            Icons.home_rounded,
            Icons.home_outlined,
            selectedIndex == 0,
          ),
          _NavDestination(
            "Index",
            Icons.menu_book_rounded,
            Icons.menu_book_outlined,
            selectedIndex == 1,
          ),
          _NavDestination(
            "Favorites",
            Icons.favorite_rounded,
            Icons.favorite_outline,
            selectedIndex == 2,
          ),
          _NavDestination(
            "Settings",
            Icons.settings_rounded,
            Icons.settings_outlined,
            selectedIndex == 3,
          ),
        ],
      ),
    );
  }
}

class _NavDestination extends StatelessWidget {
  final String label;
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final bool selected;

  const _NavDestination(
      this.label, this.selectedIcon, this.unselectedIcon, this.selected);

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: Icon(unselectedIcon, size: 26),
      selectedIcon: Icon(selectedIcon, size: 26),
      label: label,
    );
  }
}

class SanctuaryHome extends StatefulWidget {
  const SanctuaryHome({super.key});
  @override
  State<SanctuaryHome> createState() => _SanctuaryHomeState();
}

class _SanctuaryHomeState extends State<SanctuaryHome>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final hour = now.hour;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String greetingEn;
    String greetingAm;
    IconData greetingIcon;
    if (hour < 5) {
      greetingEn = "Deep Night";
      greetingAm = "ሌሊት ጥልቅ";
      greetingIcon = Icons.nightlight_round;
    } else if (hour < 12) {
      greetingEn = "Good Morning";
      greetingAm = "ጽዋዕ ማምሰል";
      greetingIcon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greetingEn = "Good Afternoon";
      greetingAm = "ጽዋዕ ሰላም";
      greetingIcon = Icons.wb_twilight_rounded;
    } else if (hour < 21) {
      greetingEn = "Good Evening";
      greetingAm = "ጽዋዕ ለምሽት";
      greetingIcon = Icons.nights_stay_rounded;
    } else {
      greetingEn = "Good Night";
      greetingAm = "ሌሊት ይማርህ";
      greetingIcon = Icons.bedtime_rounded;
    }

    final dayIndex = now.weekday % 7;
    final todayStr = PsalmRepository.daysOfWeek[dayIndex];
    final todayPsalms = PsalmRepository.getPsalmsByDay(todayStr);

    final morningPsalms = PsalmRepository.allPsalms
        .where((p) => p.tags.contains("Morning"))
        .toList();
    final middayPsalms = PsalmRepository.allPsalms
        .where((p) => p.tags.contains("Daylight"))
        .toList();
    final eveningPsalms = PsalmRepository.allPsalms
        .where((p) => p.tags.contains("Evening"))
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            toolbarHeight: 64,
            stretch: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle:
                isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroSection(
                greetingEn: greetingEn,
                greetingAm: greetingAm,
                greetingIcon: greetingIcon,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SacredAbout()),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    _TodayPrayerSection(
                      todayStr: todayStr,
                      todayPsalms: todayPsalms,
                      colorScheme: colorScheme,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 32),
                    _PrayerSection(
                      titleEn: "Morning Prayer",
                      titleAm: "ጽዋዕ ለማምሰል",
                      subtitle: "First hour — ኅዝብ ይቀድም",
                      psalms: morningPsalms,
                      accentColor: AppTheme.morningAccent,
                      colorScheme: colorScheme,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 32),
                    _PrayerSection(
                      titleEn: "Midday Prayer",
                      titleAm: "ጽዋዕ ለሰላም",
                      subtitle: "Third hour — ሦስተ ሰዓት",
                      psalms: middayPsalms,
                      accentColor: AppTheme.middayAccent,
                      colorScheme: colorScheme,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 32),
                    _PrayerSection(
                      titleEn: "Evening Prayer",
                      titleAm: "ጽዋዕ ለምሽት",
                      subtitle: "Ninth hour — ታሚት ለምሽት",
                      psalms: eveningPsalms,
                      accentColor: AppTheme.eveningAccent,
                      colorScheme: colorScheme,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AdBannerWidget(),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          _EthiopianCrossDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.25),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "መዝሙረ ዳዊት • Psalms of David • ፫.language",
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.2),
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final String greetingEn;
  final String greetingAm;
  final IconData greetingIcon;
  final bool isDark;
  final ColorScheme colorScheme;

  const _HeroSection({
    required this.greetingEn,
    required this.greetingAm,
    required this.greetingIcon,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1A0F0F),
                  const Color(0xFF0A090C),
                ]
              : [
                  const Color(0xFFF5EDE0),
                  const Color(0xFFEFE5D0),
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _EthiopianPatternPainter(
                color: colorScheme.primary.withValues(alpha: 0.04),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              greetingIcon,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              greetingEn,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: isDark
                          ? [
                              const Color(0xFFF5F0E8),
                              const Color(0xFFE8D5B0),
                            ]
                          : [
                              const Color(0xFF3D0F0F),
                              const Color(0xFF6B1C1C),
                            ],
                    ).createShader(bounds),
                    child: Text(
                      greetingAm,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? const Color(0xFFF5F0E8)
                            : const Color(0xFF3D0F0F),
                        height: 1.05,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "መዝሙረ ዳዊት — Psalms of David",
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 15,
                      color: (isDark
                              ? const Color(0xFFF5F0E8)
                              : const Color(0xFF3D0F0F))
                          .withValues(alpha: 0.4),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _StatBadge(
                        icon: Icons.book_rounded,
                        label: "150 Psalms",
                        colorScheme: colorScheme,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _StatBadge(
                        icon: Icons.format_list_numbered_rounded,
                        label: "3,374 Verses",
                        colorScheme: colorScheme,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _StatBadge(
                        icon: Icons.translate_rounded,
                        label: "3 Languages",
                        colorScheme: colorScheme,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final bool isDark;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFFF5F0E8) : const Color(0xFF3D0F0F))
            .withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? const Color(0xFFF5F0E8) : const Color(0xFF3D0F0F))
              .withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: colorScheme.onSurface.withValues(alpha: 0.45),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface.withValues(alpha: 0.45),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayPrayerSection extends StatelessWidget {
  final String todayStr;
  final List<Psalm> todayPsalms;
  final ColorScheme colorScheme;
  final bool isDark;

  const _TodayPrayerSection({
    required this.todayStr,
    required this.todayPsalms,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Prayer",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      todayStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.1),
                      colorScheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  "${todayPsalms.length} psalms",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (todayPsalms.isEmpty)
            _EmptyStateCard(
              message: "No psalm scheduled for this day.",
              colorScheme: colorScheme,
              isDark: isDark,
            )
          else
            Column(
              children: todayPsalms
                  .asMap()
                  .entries
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TodayPsalmCard(
                        psalm: e.value,
                        colorScheme: colorScheme,
                        isDark: isDark,
                        index: e.key,
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _TodayPsalmCard extends StatelessWidget {
  final Psalm psalm;
  final ColorScheme colorScheme;
  final bool isDark;
  final int index;

  const _TodayPsalmCard({
    required this.psalm,
    required this.colorScheme,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: AppSettings.favoriteIds,
      builder: (ctx, favSet, _) {
        final isFav = favSet.contains(psalm.number);
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (index * 80)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Material(
            color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
            borderRadius: BorderRadius.circular(20),
            elevation: 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ReadingSanctuary(psalm: psalm)),
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.07),
                  ),
                  gradient: isDark
                      ? LinearGradient(
                          colors: [
                            colorScheme.surfaceContainerHighest,
                            colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.15),
                            colorScheme.primary.withValues(alpha: 0.04),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "${psalm.number}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            psalm.titleAmharic,
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${psalm.verses.length} verses • ${psalm.day.split("(").first.trim()}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _GlassIconButton(
                      icon: isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline,
                      color: isFav
                          ? Colors.redAccent
                          : colorScheme.onSurface.withValues(alpha: 0.25),
                      onTap: () {
                        final current =
                            Set<int>.from(AppSettings.favoriteIds.value);
                        if (current.contains(psalm.number)) {
                          current.remove(psalm.number);
                        } else {
                          current.add(psalm.number);
                        }
                        AppSettings.favoriteIds.value = current;
                      },
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _GlassIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.08),
          ),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _PrayerSection extends StatelessWidget {
  final String titleEn;
  final String titleAm;
  final String subtitle;
  final List<Psalm> psalms;
  final Color accentColor;
  final ColorScheme colorScheme;
  final bool isDark;

  const _PrayerSection({
    required this.titleEn,
    required this.titleAm,
    required this.subtitle,
    required this.psalms,
    required this.accentColor,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (psalms.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor,
                      accentColor.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleEn,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          titleAm,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 12,
                            color: accentColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "• $subtitle",
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.28),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  "${psalms.length}",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: psalms.length.clamp(0, 10),
              itemBuilder: (ctx, i) {
                return _GlassPsalmCard(
                  psalm: psalms[i],
                  accentColor: accentColor,
                  colorScheme: colorScheme,
                  isDark: isDark,
                  index: i,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPsalmCard extends StatelessWidget {
  final Psalm psalm;
  final Color accentColor;
  final ColorScheme colorScheme;
  final bool isDark;
  final int index;

  const _GlassPsalmCard({
    required this.psalm,
    required this.accentColor,
    required this.colorScheme,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReadingSanctuary(psalm: psalm)),
        ),
        child: Container(
          width: 160,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      colorScheme.surfaceContainerHighest,
                      colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.6),
                    ]
                  : [
                      Colors.white,
                      Colors.white.withValues(alpha: 0.85),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : accentColor)
                    .withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor,
                      accentColor.withValues(alpha: 0.4),
                    ],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "#${psalm.number}",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: accentColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: colorScheme.onSurface.withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: Text(
                          psalm.titleAmharic,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            height: 1.4,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              psalm.day.split("(").first.trim(),
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.32),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String message;
  final ColorScheme colorScheme;
  final bool isDark;

  const _EmptyStateCard({
    required this.message,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.05),
        ),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.28),
          ),
        ),
      ),
    );
  }
}

class _EthiopianCrossDecoration extends StatelessWidget {
  final Color color;
  const _EthiopianCrossDecoration({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 36),
      painter: _EthiopianCrossPainter(color: color),
    );
  }
}

class _EthiopianCrossPainter extends CustomPainter {
  final Color color;
  _EthiopianCrossPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final arm = size.width * 0.38;

    canvas.drawLine(
      Offset(cx, cy - arm),
      Offset(cx, cy + arm),
      paint,
    );
    canvas.drawLine(
      Offset(cx - arm, cy),
      Offset(cx + arm, cy),
      paint,
    );

    canvas.drawCircle(
        Offset(cx, cy - arm), 2.5, paint..style = PaintingStyle.fill);
    canvas.drawCircle(
        Offset(cx, cy + arm), 2.5, paint..style = PaintingStyle.fill);
    canvas.drawCircle(
        Offset(cx - arm, cy), 2.5, paint..style = PaintingStyle.fill);
    canvas.drawCircle(
        Offset(cx + arm, cy), 2.5, paint..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy), 3.5, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EthiopianPatternPainter extends CustomPainter {
  final Color color;
  _EthiopianPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const spacing = 40.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LibrarySearchHub extends StatefulWidget {
  const LibrarySearchHub({super.key});
  @override
  State<LibrarySearchHub> createState() => _LibrarySearchHubState();
}

class _LibrarySearchHubState extends State<LibrarySearchHub> {
  String _query = "";
  String? _selectedTag;
  final _searchController = TextEditingController();

  List<String> get _allTags {
    final tags = <String>{};
    for (final p in PsalmRepository.allPsalms) {
      tags.addAll(p.tags);
    }
    return tags.toList()..sort();
  }

  List<Psalm> get _filtered {
    return PsalmRepository.allPsalms.where((p) {
      final matchesQuery = _query.isEmpty ||
          p.titleAmharic.toLowerCase().contains(_query.toLowerCase()) ||
          p.day.toLowerCase().contains(_query.toLowerCase()) ||
          "${p.number}".contains(_query);
      final matchesTag = _selectedTag == null || p.tags.contains(_selectedTag);
      return matchesQuery && matchesTag;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tags = _allTags;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 140,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Psalm Index",
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${_filtered.length}",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "All 150 sacred psalms of David",
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: _GlassSearchBar(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                colorScheme: colorScheme,
                isDark: isDark,
              ),
            ),
          ),
          if (tags.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 46,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _AnimatedFilterChip(
                      label: "All",
                      selected: _selectedTag == null,
                      onTap: () => setState(() => _selectedTag = null),
                      colorScheme: colorScheme,
                    ),
                    ...tags.map((tag) => _AnimatedFilterChip(
                          label: tag,
                          selected: _selectedTag == tag,
                          onTap: () => setState(() =>
                              _selectedTag = _selectedTag == tag ? null : tag),
                          colorScheme: colorScheme,
                        )),
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AdBannerWidget(),
            ),
          ),
          if (_filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.search_off_rounded,
                        size: 40,
                        color: colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "No psalms found",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Try adjusting your search or filter",
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _LibraryPsalmTile(
                  psalm: _filtered[i],
                  colorScheme: colorScheme,
                  isDark: isDark,
                  index: i,
                ),
                childCount: _filtered.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ColorScheme colorScheme;
  final bool isDark;

  const _GlassSearchBar({
    required this.controller,
    required this.onChanged,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: "Search by title, day, or number...",
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.28),
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 4),
          child: Icon(
            Icons.search_rounded,
            color: colorScheme.primary,
            size: 22,
          ),
        ),
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
            : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.07),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _AnimatedFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _AnimatedFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.1),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryPsalmTile extends StatelessWidget {
  final Psalm psalm;
  final ColorScheme colorScheme;
  final bool isDark;
  final int index;

  const _LibraryPsalmTile({
    required this.psalm,
    required this.colorScheme,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: AppSettings.favoriteIds,
      builder: (ctx, favSet, _) {
        final isFav = favSet.contains(psalm.number);
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 40)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 15 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ReadingSanctuary(psalm: psalm)),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.12),
                            colorScheme.primary.withValues(alpha: 0.03),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "${psalm.number}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            psalm.titleAmharic,
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.35),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "${psalm.day.split("(").first.trim()} • ${psalm.verses.length} verses",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _GlassIconButton(
                      icon: isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline,
                      color: isFav
                          ? Colors.redAccent
                          : colorScheme.onSurface.withValues(alpha: 0.2),
                      onTap: () {
                        final current =
                            Set<int>.from(AppSettings.favoriteIds.value);
                        if (current.contains(psalm.number)) {
                          current.remove(psalm.number);
                        } else {
                          current.add(psalm.number);
                        }
                        AppSettings.favoriteIds.value = current;
                      },
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.15),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FavoritesSanctuary extends StatelessWidget {
  const FavoritesSanctuary({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 110,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          "Favorites",
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        ValueListenableBuilder<Set<int>>(
                          valueListenable: AppSettings.favoriteIds,
                          builder: (ctx, favSet, _) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${favSet.length}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AdBannerWidget(),
            ),
          ),
          SliverFillRemaining(
            child: ValueListenableBuilder<Set<int>>(
              valueListenable: AppSettings.favoriteIds,
              builder: (ctx, favSet, _) {
                final favs = PsalmRepository.allPsalms
                    .where((p) => favSet.contains(p.number))
                    .toList();
                if (favs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary.withValues(alpha: 0.06),
                                colorScheme.primary.withValues(alpha: 0.02),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite_outline,
                            size: 40,
                            color: colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "No favorites yet",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Tap the heart on any psalm\nto save it here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  itemCount: favs.length,
                  itemBuilder: (ctx, i) => _LibraryPsalmTile(
                    psalm: favs[i],
                    colorScheme: colorScheme,
                    isDark: isDark,
                    index: i,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReadingSanctuary extends StatefulWidget {
  final Psalm psalm;
  const ReadingSanctuary({super.key, required this.psalm});
  @override
  State<ReadingSanctuary> createState() => _ReadingSanctuaryState();
}

class _ReadingSanctuaryState extends State<ReadingSanctuary>
    with SingleTickerProviderStateMixin {
  String _lang = "AM";
  final ScrollController _scrollController = ScrollController();
  int _lastInterstitialVerseIndex = -1;
  static const int _interstitialEvery = 5;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    AdService.resetVerseInterstitialCount();
    _scrollController.addListener(_onScroll);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_lang != "EN") return;
    if (!AdService.shouldShowVerseInterstitial()) return;
    if (!_scrollController.hasClients) return;

    final extentBefore = _scrollController.position.extentBefore;
    const estimatedVerseHeight = 130.0;
    final currentVerseIndex = (extentBefore / estimatedVerseHeight).floor();

    if (currentVerseIndex >= _lastInterstitialVerseIndex + _interstitialEvery) {
      _lastInterstitialVerseIndex = currentVerseIndex;
      AdService.showVerseInterstitial();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.psalm;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 170,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle:
                isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF1A0F0F),
                            Theme.of(context).scaffoldBackgroundColor,
                          ]
                        : [
                            const Color(0xFFF5EDE0),
                            Theme.of(context).scaffoldBackgroundColor,
                          ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.12),
                                ),
                              ),
                              child: Text(
                                "Psalm ${p.number}",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "${p.verses.length} verses",
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.32),
                              ),
                            ),
                            const Spacer(),
                            ...p.tags.take(2).map((tag) => Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFFF5F0E8),
                                    const Color(0xFFE8D5B0),
                                  ]
                                : [
                                    const Color(0xFF3D0F0F),
                                    const Color(0xFF6B1C1C),
                                  ],
                          ).createShader(bounds),
                          child: Text(
                            p.titleAmharic,
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? const Color(0xFFF5F0E8)
                                  : const Color(0xFF3D0F0F),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.day,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.primary.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              ValueListenableBuilder<Set<int>>(
                valueListenable: AppSettings.favoriteIds,
                builder: (ctx, favSet, _) {
                  final isFav = favSet.contains(p.number);
                  return IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_outline,
                        color: isFav ? Colors.redAccent : colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    onPressed: () {
                      final current =
                          Set<int>.from(AppSettings.favoriteIds.value);
                      if (current.contains(p.number)) {
                        current.remove(p.number);
                      } else {
                        current.add(p.number);
                      }
                      AppSettings.favoriteIds.value = current;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            current.contains(p.number)
                                ? "Added to favorites"
                                : "Removed from favorites",
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeController,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Row(
                  children: [
                    _LangPill(
                      label: "አማርኛ",
                      code: "AM",
                      selected: _lang == "AM",
                      onTap: () => setState(() => _lang = "AM"),
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(width: 8),
                    _LangPill(
                      label: "ግዕዝ",
                      code: "GE",
                      selected: _lang == "GE",
                      onTap: () => setState(() => _lang = "GE"),
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(width: 8),
                    _LangPill(
                      label: "English",
                      code: "EN",
                      selected: _lang == "EN",
                      onTap: () => setState(() => _lang = "EN"),
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_lang == "EN")
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeController,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: _EnglishAdNotice(colorScheme: colorScheme),
                ),
              ),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final v = p.verses[i];
                String txt = _lang == "AM"
                    ? v.amharic
                    : _lang == "GE"
                        ? v.geez
                        : v.english;
                final hasTranslation = txt.isNotEmpty;

                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _fadeController,
                    curve: Interval(
                      (i / p.verses.length) * 0.4,
                      ((i / p.verses.length) * 0.4 + 0.6).clamp(0.0, 1.0),
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      i == 0 ? 4 : 0,
                      24,
                      i == p.verses.length - 1 ? 120 : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _VerseDisplay(
                          number: v.number,
                          text: txt,
                          hasTranslation: hasTranslation,
                          fontSize: AppSettings.fontSize.value,
                          colorScheme: colorScheme,
                          isDark: isDark,
                          isLast: i == p.verses.length - 1,
                        ),
                        if (i < p.verses.length - 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: _VerseDivider(color: colorScheme.primary),
                          ),
                      ],
                    ),
                  ),
                );
              },
              childCount: p.verses.length,
            ),
          ),
          if (_lang == "EN")
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeController,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 20),
                  child: Center(child: AdBannerWidget()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LangPill extends StatelessWidget {
  final String label;
  final String code;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _LangPill({
    required this.label,
    required this.code,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.09),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected
                ? colorScheme.onPrimary
                : colorScheme.onSurface.withValues(alpha: 0.5),
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _VerseDisplay extends StatelessWidget {
  final int number;
  final String text;
  final bool hasTranslation;
  final double fontSize;
  final ColorScheme colorScheme;
  final bool isDark;
  final bool isLast;

  const _VerseDisplay({
    required this.number,
    required this.text,
    required this.hasTranslation,
    required this.fontSize,
    required this.colorScheme,
    required this.isDark,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.12),
                colorScheme.primary.withValues(alpha: 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "$number",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: hasTranslation
                ? Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: fontSize,
                      color: colorScheme.onSurface.withValues(alpha: 0.9),
                      height: 1.85,
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        Icons.translate,
                        size: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Translation not available",
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: fontSize * 0.9,
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onSurface.withValues(alpha: 0.22),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _VerseDivider extends StatelessWidget {
  final Color color;
  const _VerseDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 48),
        Container(
          width: 32,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.12),
                color.withValues(alpha: 0.04),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Icon(
          Icons.remove,
          size: 8,
          color: color.withValues(alpha: 0.2),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.04),
                  color.withValues(alpha: 0.12),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EnglishAdNotice extends StatelessWidget {
  final ColorScheme colorScheme;
  const _EnglishAdNotice({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surfaceContainerHighest,
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.translate,
            size: 13,
            color: colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(width: 6),
          Text(
            "English Translation",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(width: 8),
          const AdBannerWidget(),
        ],
      ),
    );
  }
}

class DivineSettings extends StatelessWidget {
  const DivineSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 110,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Settings",
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsGroup(
                    title: "APPEARANCE",
                    accent: colorScheme.primary,
                    colorScheme: colorScheme,
                    isDark: isDark,
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: AppSettings.isDarkMode,
                        builder: (ctx, val, _) => _SettingsTile(
                          icon: val
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          iconColor: colorScheme.primary,
                          title: "Dark Mode",
                          subtitle:
                              val ? "Dark theme active" : "Light theme active",
                          trailing: Switch(
                            value: val,
                            onChanged: (v) => AppSettings.isDarkMode.value = v,
                          ),
                          colorScheme: colorScheme,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SettingsGroup(
                    title: "READING",
                    accent: const Color(0xFF9B7A3C),
                    colorScheme: colorScheme,
                    isDark: isDark,
                    children: [
                      ValueListenableBuilder<double>(
                        valueListenable: AppSettings.fontSize,
                        builder: (ctx, val, _) => _SettingsTile(
                          icon: Icons.text_fields_rounded,
                          iconColor: const Color(0xFF9B7A3C),
                          title: "Text Size",
                          subtitle: "${val.toInt()} pt",
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _SizeButton(
                                icon: Icons.remove,
                                onTap: () {
                                  if (AppSettings.fontSize.value > 14) {
                                    AppSettings.fontSize.value -= 2;
                                  }
                                },
                                colorScheme: colorScheme,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  "${val.toInt()}",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              _SizeButton(
                                icon: Icons.add,
                                onTap: () {
                                  if (AppSettings.fontSize.value < 44) {
                                    AppSettings.fontSize.value += 2;
                                  }
                                },
                                colorScheme: colorScheme,
                              ),
                            ],
                          ),
                          colorScheme: colorScheme,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SettingsGroup(
                    title: "ABOUT",
                    accent: colorScheme.tertiary,
                    colorScheme: colorScheme,
                    isDark: isDark,
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        iconColor: colorScheme.tertiary,
                        title: "About Mezmure Dawit",
                        subtitle: "Version 1.0.8",
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.onSurface.withValues(alpha: 0.2),
                          size: 22,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SacredAbout()),
                        ),
                        colorScheme: colorScheme,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Center(
                    child: Column(
                      children: [
                        _EthiopianCrossDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.18)),
                        const SizedBox(height: 14),
                        Text(
                          "መዝሙረ ዳዊት",
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 16,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _SizeButton({
    required this.icon,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.08),
          ),
        ),
        child: Icon(icon, size: 16, color: colorScheme.primary),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final Color accent;
  final ColorScheme colorScheme;
  final bool isDark;
  final List<Widget> children;

  const _SettingsGroup({
    required this.title,
    required this.accent,
    required this.colorScheme,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.06),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final ColorScheme colorScheme;
  final bool isDark;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.colorScheme,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.08),
              ),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: content,
      );
    }
    return content;
  }
}

class SacredAbout extends StatelessWidget {
  const SacredAbout({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            title: Text(
              "About",
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.18),
                          colorScheme.primary.withValues(alpha: 0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "መዝ",
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "መዝሙረ ዳዊት",
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Mezmure Dawit",
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Text(
                      "A sacred digital manuscript displaying Ge'ez, Amharic, and English psalms. Designed for daily prayer and meditation. All 150 psalms of David in trilingual format.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 15,
                        height: 1.75,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _AboutStatCard(
                    icon: Icons.book_rounded,
                    label: "Total Psalms",
                    value: "150",
                    accent: colorScheme.primary,
                    colorScheme: colorScheme,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _AboutStatCard(
                    icon: Icons.format_list_numbered_rounded,
                    label: "Total Verses",
                    value: "3,374",
                    accent: AppTheme.morningAccent,
                    colorScheme: colorScheme,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _AboutStatCard(
                    icon: Icons.translate_rounded,
                    label: "Languages",
                    value: "Amharic • Ge'ez • English",
                    accent: AppTheme.eveningAccent,
                    colorScheme: colorScheme,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 48),
                  _EthiopianCrossDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.2)),
                  const SizedBox(height: 18),
                  Text(
                    "Version 1.0.8",
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.22),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final ColorScheme colorScheme;
  final bool isDark;

  const _AboutStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colorScheme.surfaceContainerHighest,
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                ]
              : [Colors.white, Colors.white.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : accent).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: accent.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accent,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
