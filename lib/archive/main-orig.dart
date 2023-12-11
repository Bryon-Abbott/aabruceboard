//import 'package:farklescore/pages/settings_scoring.dart';
//import 'package:bruceboard/theme/thememanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:bruceboard/shared/loading.dart';
import 'package:bruceboard/pages/general/home.dart';
import 'package:bruceboard/pages/general/about.dart';
import 'package:bruceboard/pages/manage_players.dart';
import 'package:bruceboard/pages/maintain_player.dart';
import 'package:bruceboard/pages/manage_games.dart';
import 'package:bruceboard/pages/maintain_game.dart';
import 'package:bruceboard/pages/game_board.dart';
import 'package:bruceboard/pages/settings/settings_main.dart';
import 'package:bruceboard/pages/settings_scoring.dart';
import 'package:bruceboard/utils/preferences.dart';
import 'package:bruceboard/utils/downloadgame.dart';
import 'package:bruceboard/theme/theme_constants.dart';

import '../firebase_options.dart';
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
  final AdaptiveThemeMode savedThemeModex = await AdaptiveTheme.getThemeMode() ??
      AdaptiveThemeMode.light;

  await Settings.init(cacheProvider: SharePreferenceCache());
  await Preferences.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // RootApp(savedThemeMode: savedThemeModex),
    const RootApp(),
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
  //          '/home': (context) => Home(savedThemeMode: savedThemeMode, onChanged: onChanged),
            '/home': (context) => const Home(),
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