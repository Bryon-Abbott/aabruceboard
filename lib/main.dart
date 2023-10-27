import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter/foundation.dart';

import 'package:provider/provider.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:bruceboard/pages/auth/authenticate.dart';
import 'package:bruceboard/pages/series/series_list.dart';
import 'package:bruceboard/pages/series/series_maintain.dart';
import 'package:bruceboard/pages/community/community_list.dart';
import 'package:bruceboard/pages/community/community_maintain.dart';
import 'package:bruceboard/pages/player/profile.dart';
import 'package:bruceboard/services/auth.dart';
import 'package:bruceboard/theme/theme_constants.dart';
import 'package:bruceboard/utils/preferences.dart';
import 'package:bruceboard/models/player.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bruceboard/pages/loading.dart';
import 'package:bruceboard/pages/home.dart';
import 'package:bruceboard/pages/about.dart';
import 'package:bruceboard/pages/manage_players.dart';
import 'package:bruceboard/pages/maintain_player.dart';
import 'package:bruceboard/pages/manage_games.dart';
import 'package:bruceboard/pages/maintain_game.dart';
import 'package:bruceboard/pages/settings_main.dart';
import 'package:bruceboard/pages/settings_scoring.dart';

import 'firebase_options.dart';


import 'firebase_options.dart';
main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AdaptiveThemeMode? savedThemeModex = await AdaptiveTheme.getThemeMode() ??
      AdaptiveThemeMode.light;

  await Settings.init(cacheProvider: SharePreferenceCache());
  await Preferences.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
    );
  }
}

class LoadApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  final VoidCallback onChanged;

  const LoadApp({
    super.key,
    this.savedThemeMode,
    required this.onChanged,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<BruceUser?>.value(
      initialData: null, // BruceUser(uid: 'x'),
      value: AuthService().user,
        child: AdaptiveTheme(
          light: lightTheme,
          dark: darkTheme,
          debugShowFloatingThemeButton: false,
          initial: savedThemeMode ?? AdaptiveThemeMode.light,
          builder: (theme, lightTheme) =>
          MaterialApp(
            title: 'Bruce Board',
//          theme: lightTheme,
            theme: theme,
            darkTheme: darkTheme,
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => Loading(),
              // '/home': (context) => Home(savedThemeMode: savedThemeMode, onChanged: onChanged),
              '/home': (context) => Home(),
              '/manageplayers': (context) => const ManagePlayers(),
              '/maintainplayer': (context) => const MaintainPlayer(),
              '/managegames': (context) => const ManageGames(),
              '/maintaingame': (context) => const MaintainGame(),
              '/about': (context) => const About(),
              '/authenticate': (contexct) => const Authenticate(),
              '/profile': (context) => SettingsForm(),
              '/series-list': (context) => const SeriesList(),
              '/series-maintain': (context) => const SeriesMaintain(),
              '/community-list': (context) => const CommunityList(),
              '/community-maintain': (context) => const CommunityMaintain(),
              '/settings': (context) => const SettingsMain(),
              // Not sure I need this?
              '/settings_scoring': (context) => const SettingsScoring(),
              // Not sure I need this?
            },
          ),
        ),
    );
  }
}