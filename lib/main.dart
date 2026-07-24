// Main App Widget with Routing and Providers

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/storage/storage_repository_impl.dart';
import 'providers/zikr_providers.dart';
import 'presentation/screens/main/main_screen.dart';
import 'presentation/screens/zikrs/zikrs_screen.dart';
import 'presentation/screens/path/path_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters
  _registerAdapters();
  
  runApp(const ProviderScope(child: ZikrSunnahApp()));
}

void _registerAdapters() {
  Hive
    ..registerAdapter(ZikrAdapter())
    ..registerAdapter(AppSettingsAdapter())
    ..registerAdapter(DailyStatAdapter())
    ..registerAdapter(ZikrSessionAdapter())
    ..registerAdapter(BackupDataAdapter())
    ..registerAdapter(ZikrCategoryAdapter())
    ..registerAdapter(ThemeModeAdapter())
    ..registerAdapter(HapticIntensityAdapter())
    ..registerAdapter(NumberFormatTypeAdapter())
    ..registerAdapter(SessionTypeAdapter());
}

class ZikrSunnahApp extends ConsumerWidget {
  const ZikrSunnahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize storage
    ref.watch(initializeStorageProvider);
    
    // Watch theme and locale
    final theme = ref.watch(appThemeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Зикр по Сунне',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      locale: locale,
      supportedLocales: supportedLocales,
      localeResolutionCallback: localeResolutionCallback,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const MainNavigationScreen(),
      routes: {
        '/zikrs': (context) => const ZikrsScreen(),
        '/path': (context) => const PathScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  
  final List<Widget> _screens = [
    const MainScreen(),
    const ZikrsScreen(),
    const PathScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.prayer_rounded, size: 24),
            selectedIcon: Icon(Icons.prayer_rounded, size: 26, color: colorScheme.onPrimary),
            label: l10n.counter,
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_rounded, size: 24),
            selectedIcon: Icon(Icons.menu_book_rounded, size: 26, color: colorScheme.onPrimary),
            label: l10n.zikrs,
          ),
          NavigationDestination(
            icon: Icon(Icons.route_rounded, size: 24),
            selectedIcon: Icon(Icons.route_rounded, size: 26, color: colorScheme.onPrimary),
            label: l10n.path,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded, size: 24),
            selectedIcon: Icon(Icons.settings_rounded, size: 26, color: colorScheme.onPrimary),
            label: l10n.settings,
          ),
        ],
        height: 72,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}

// Locale Provider
@riverpod
Locale locale(LocaleRef ref) {
  // TODO: Load from settings
  return const Locale('ru');
}