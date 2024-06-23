//import 'dart:async';
import 'dart:developer';

import 'package:bruceboard/models/membershipprovider.dart';
import 'package:bruceboard/pages/message/message_list_incoming.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'firebase_options.dart';

import 'package:bruceboard/shared/loading.dart';
import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/models/communityplayerprovider.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/auth.dart';
import 'package:bruceboard/theme/theme_constants.dart';
import 'package:bruceboard/utils/preferences.dart';

import 'package:bruceboard/pages/auth/authenticate.dart';
import 'package:bruceboard/pages/series/series_list.dart';
import 'package:bruceboard/pages/series/series_maintain.dart';
import 'package:bruceboard/pages/community/community_list.dart';
import 'package:bruceboard/pages/community/community_maintain.dart';
import 'package:bruceboard/pages/membership/membership_list.dart';
import 'package:bruceboard/pages/membership/membership_maintain.dart';
import 'package:bruceboard/pages/community/community_select.dart';
import 'package:bruceboard/pages/community/community_select_owner.dart';
import 'package:bruceboard/pages/player/player_select.dart';
import 'package:bruceboard/pages/general/home.dart';
import 'package:bruceboard/pages/general/about.dart';
import 'package:bruceboard/pages/settings/settings_main.dart';
import 'package:bruceboard/pages/settings/settings_scoring.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

//  final AdaptiveThemeMode savedThemeModex = await AdaptiveTheme.getThemeMode() ??
//      AdaptiveThemeMode.light;
//   WidgetsFlutterBinding.ensureInitialized();
//   unawaited(MobileAds.instance.initialize());

  await Preferences.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
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
      initialData: BruceUser(),
      value: AuthService().user,
      child: MultiProvider(
        providers: [
          Provider<ActivePlayerProvider>(create: (_) => ActivePlayerProvider()),
          Provider<CommunityPlayerProvider>(create: (_) => CommunityPlayerProvider()),
          Provider<MembershipProvider>(create: (_) => MembershipProvider()),
        ],
        child: AdaptiveTheme(
          light: lightTheme,
          dark: darkTheme,
          debugShowFloatingThemeButton: false,
          initial: savedThemeMode ?? AdaptiveThemeMode.light,
          builder: (theme, lightTheme) {
            log('Return MaterialApp', name: '${runtimeType.toString()}:build()');
            return MaterialApp(
              title: 'Bruce Board',
              //          theme: lightTheme,
              theme: theme,
              darkTheme: darkTheme,
              debugShowCheckedModeBanner: false,
              initialRoute: '/home',
              routes: {
                '/': (context) => const Loading(),
                // '/home': (context) => Home(savedThemeMode: savedThemeMode, onChanged: onChanged),
                '/home': (context) => const Home(),
                // '/manageplayers': (context) => const ManagePlayers(),
                // '/maintainplayer': (context) => const MaintainPlayer(),
                // '/managegames': (context) => const ManageGames(),
                // '/maintaingame': (context) => const MaintainGame(),
                '/about': (context) => const About(),
                '/authenticate': (context) => const Authenticate(),
                // '/player-profile': (context) => const PlayerProfilePage(),
                // '/player-profile': (context) => const PlayerProfile(),
                '/player-select': (context) => const PlayerSelect(),
                '/series-list': (context) => const SeriesList(),
            //    '/message-list': (context) => const MessageOwnerList(),
                '/message-list-incoming': (context) => const MessageListIncoming(),
                '/series-maintain': (context) => const SeriesMaintain(),
                '/community-list': (context) => const CommunityList(),
                '/community-maintain': (context) => const CommunityMaintain(),
                '/community-select': (context) => const CommunitySelect(),
                '/community-select-owner': (context) => const CommunitySelectOwner(),
                '/membership-list': (context) => const MembershipList(),
                '/membership-maintain': (context) => const MembershipMaintain(),
                '/settings': (context) => const SettingsMain(),
                // Not sure I need this?
                '/settings_scoring': (context) => const SettingsScoring(),
                // Not sure I need this?
              },
            );
          }
        ),
      ),
    );
  }
}