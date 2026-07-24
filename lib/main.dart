import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localizations.dart';
import 'core/models/models.dart';
import 'core/theme/theme.dart';
import 'presentation/providers/providers.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/path_screen.dart';
import 'presentation/screens/settings_screen.dart';

void main() {
  runApp(const ProviderScope(child: ZikrSunnahApp()));
}

class ZikrSunnahApp extends ConsumerWidget {
  const ZikrSunnahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ready = ref.watch(storageReadyProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Зикр по Сунне',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _resolveThemeMode(settings.themeMode),
      locale: Locale(settings.languageCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ready.when(
        loading: () => const _Splash(),
        error: (e, _) => _Error(message: e.toString()),
        data: (_) => const HomeShell(),
      ),
    );
  }

  ThemeMode _resolveThemeMode(AppThemeMode mode) => switch (mode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      };
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkBackground,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.islamicGold,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final String message;
  const _Error({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkBackground,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(color: AppColors.darkTextPrimary),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Нижняя навигация: Зикры (главный), Путь, Настройки.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = <Widget>[
    MainScreen(),
    PathScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            activeIcon: const Icon(Icons.favorite),
            label: l.zikrs,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_outlined),
            label: l.path,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: l.settings,
          ),
        ],
      ),
    );
  }
}
