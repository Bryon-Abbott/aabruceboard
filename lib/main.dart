//import 'package:farklescore/pages/settings_scoring.dart';
//import 'package:bruceboard/theme/thememanager.dart';
import 'package:bruceboard/theme/themeconstants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:bruceboard/pages/loading.dart';
import 'package:bruceboard/pages/home.dart';
import 'package:bruceboard/pages/about.dart';
import 'package:bruceboard/pages/manageplayers.dart';
import 'package:bruceboard/pages/maintainplayer.dart';
import 'package:bruceboard/pages/managegames.dart';
import 'package:bruceboard/pages/maintaingame.dart';
import 'package:bruceboard/pages/gameboard.dart';
import 'package:bruceboard/pages/settings_main.dart';
import 'package:bruceboard/pages/settings_scoring.dart';
import 'package:bruceboard/utils/preferences.dart';
import 'package:bruceboard/utils/downloadgame.dart';
import 'package:bruceboard/theme/themeconstants.dart';
// ==========
// Desc: Main module for the BruceBoard application.
// ----------
// Features;
// ----------
// 2023/09/12 Bryon   Created
// ==========

// ============================================================================
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AdaptiveThemeMode? savedThemeModex = await AdaptiveTheme.getThemeMode() ??
      AdaptiveThemeMode.light;

  await Settings.init(cacheProvider: SharePreferenceCache());
  await Preferences.init();

  runApp(
    // RootApp(savedThemeMode: savedThemeModex),
    RootApp(),
  );
}

// ============================================================================
class RootApp extends StatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const RootApp({super.key, this.savedThemeMode});
//  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}
class _RootAppState extends State<RootApp> {
  //bool isMaterial = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      child: LoadApp(
        savedThemeMode: widget.savedThemeMode,
        onChanged: () => setState(() {}),
//        onChanged: () => setState(() => isMaterial = false),
      ),
      // child: isMaterial
      //     ? MaterialExample(
      //     savedThemeMode: widget.savedThemeMode,
      //     onChanged: () => setState(() => isMaterial = false))
      //     : CupertinoExample(
      //     savedThemeMode: widget.savedThemeMode,
      //     onChanged: () => setState(() => isMaterial = true)),
    );
  }
}

// ===========================================================================
class LoadApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  final VoidCallback onChanged;

  const LoadApp({
    super.key,
    this.savedThemeMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    // AdaptiveTheme.of(context).setTheme(
    //   light: lightTheme,
    //   dark: darkTheme,
    // );

    // Check this on different platforms (doesn't seem to work on web)
    // debugShowFloatingThemeButton: true,


    return
      AdaptiveTheme(
        light: lightTheme,
        dark: darkTheme,
        // light: ThemeData.light(),
        // dark: ThemeData.dark(),
        debugShowFloatingThemeButton: false,
        initial: savedThemeMode ?? AdaptiveThemeMode.light,
        builder: (theme, darkTheme) =>
        MaterialApp(
          title: 'Bruce Board',
//          theme: lightTheme,
          theme: theme,
          darkTheme: darkTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const Loading(),
            '/home': (context) => Home(savedThemeMode: savedThemeMode, onChanged: onChanged),
  //          '/home': (context) => Home(),
            '/manageplayers': (context) => const ManagePlayers(),
            '/maintainplayer': (context) => const MaintainPlayer(),
            '/managegames': (context) => const ManageGames(),
            '/maintaingame': (context) => const MaintainGame(),
  //          '/gameboard': (context) => GameBoard(),
            '/gameboard': (context) => GameBoard(gameStorage: DownloadGame()),
            '/about': (context) => const About(),
            '/settings': (context) => const SettingsMain(),
            // Not sure I need this?
            '/settings_scoring': (context) => const SettingsScoring(),
            // Not sure I need this?
          },
        ),
      );
  }
}