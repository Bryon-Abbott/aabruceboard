import 'dart:async';
import 'dart:developer';

import 'package:bruceboard/models/membershipprovider.dart';
import 'package:bruceboard/pages/general/home2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'firebase_options.dart';

import 'package:bruceboard/shared/loading.dart';
import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/models/communityplayerprovider.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/authservices.dart';
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
import 'package:bruceboard/pages/general/home1.dart';
import 'package:bruceboard/pages/general/about.dart';
import 'package:bruceboard/pages/settings/settings_scoring.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    log('Setting up MobileAds $kIsWeb', name: 'main()');
    unawaited(MobileAds.instance.initialize());
  }

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
    bool newInterface = Preferences.getPreferenceBool(Preferences.keyNewInterface) ?? true;
    String initialRoot = (newInterface==true) ? '/home2' : '/home1';
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
            log('Return MaterialApp - New Interface $newInterface Initial Root: $initialRoot', name: '${runtimeType.toString()}:build()');
            return MaterialApp(
              title: 'BruceBoard',
              //          theme: lightTheme,
              theme: theme,
              darkTheme: darkTheme,
              debugShowCheckedModeBanner: false,
              initialRoute: initialRoot,
              routes: {
                '/': (context) => const Loading(),
                '/home1': (context) => const Home1(),
                '/home2': (context) => const Home2(),
                '/about': (context) => const About(),
                '/authenticate': (context) => const Authenticate(),
                '/player-select': (context) => const PlayerSelect(),
                '/series-list': (context) => const SeriesList(),
                '/series-maintain': (context) => const SeriesMaintain(),
                '/community-list': (context) => const CommunityList(),
                '/community-maintain': (context) => const CommunityMaintain(),
                '/community-select': (context) => const CommunitySelect(),
                '/community-select-owner': (context) => const CommunitySelectOwner(),
                '/membership-list': (context) => const MembershipList(),
                '/membership-maintain': (context) => const MembershipMaintain(),
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