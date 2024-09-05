import 'dart:developer';
import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/pages/game/game_list_public.dart';
import 'package:bruceboard/pages/message/message_list_incoming.dart';
import 'package:bruceboard/pages/player/player_profile_page.dart';
import 'package:bruceboard/utils/banner_ad.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bruceboard/pages/auth/sign_in_message.dart';

import 'package:bruceboard/theme/theme_manager.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/communityplayerprovider.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/services/authservices.dart';
import 'package:bruceboard/pages/settings/settings_main.dart';
// ==========
// Desc: Home Screen Interface 2.0
// ----------
// 2023/09/12 Bryon   Created
// ==========
const List<Widget> kPermission = <Widget>[
  Text('My Communities'),
  Text('Public Games'),
];

class Home2 extends StatefulWidget {
  const Home2({super.key});

  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> {
  late CommunityPlayerProvider communityPlayerProvider; // = Provider.of<CommunityPlayerProvider>(context);
  late ActivePlayerProvider activePlayerProvider; // = Provider.of<ActivePlayerProvider>(context);
  Player player = Player(data: {});
  final List<bool> _selectedPermission = <bool>[false, true];

  @override
  void dispose() {
    themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    themeManager.addListener(themeListener);
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final BruceUser bruceUser = Provider.of<BruceUser?>(context) ?? BruceUser();
    log('Start of Build: ${bruceUser.uid} ${bruceUser.displayName} Is Web: $kIsWeb',
        name: "${runtimeType.toString()}:build()");

    communityPlayerProvider = Provider.of<CommunityPlayerProvider>(context);
    activePlayerProvider = Provider.of<ActivePlayerProvider>(context);
    // Player player = Player(data: {});;

    // Calculate screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double newScreenHeight = screenHeight - padding.top - padding.bottom;
    double newScreenWidth = screenWidth - padding.left - padding.right;
    //dev.log("Screen Dimensions are Height: $screenHeight, Width: $screenWidth : Height: $newScreenHeight, Width: $newScreenWidth", name: " ${this.runtimeType.toString()}:build");

    return SafeArea(
      child: FutureBuilder<FirestoreDoc?>(
        future: DatabaseService(FSDocType.player).fsDoc(key: bruceUser.uid),
        builder: (BuildContext context, AsyncSnapshot<FirestoreDoc?> snapshot) {
          // Default communityPlayer if not set yet
          if (snapshot.hasData) {
            if (snapshot.data!.docId != -1) {
              player = snapshot.data as Player;
              activePlayerProvider.activePlayer = player;
              if (communityPlayerProvider.communityPlayer.uid == 'Anonymous') {
                communityPlayerProvider.communityPlayer = player;
              }
            } else {
              activePlayerProvider.activePlayer = Player(data: {});
              communityPlayerProvider.communityPlayer = Player(data: {});
            }
            log('Player Data Found: ${player.uid} ${player.fName} ${player.lName} Is Web: $kIsWeb',
                name: "${runtimeType.toString()}:build()");
          }
          return PopScope(
            canPop: false,
            child: Scaffold(
              backgroundColor: Colors.grey,
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(0)),
                  onPressed: null,
                ),
                title: const Text('Home'),
                centerTitle: true,
                elevation: 0,
                actions: [
                  (bruceUser.uid == 'Anonymous')
                  ? IconButton(
                      onPressed: signIn,
                      icon: const Icon(Icons.person_add_rounded)
                  )
                  : IconButton(
                      onPressed: signOut,
                      icon: const Icon(Icons.person_remove_rounded)
                  ),
                  PopupMenuButton<int>(
                    onSelected: (item) => onMenuSelected(context, item),
                    itemBuilder: (context) => [
                    const PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(Icons.person_outline),
                          SizedBox(width: 8),
                          Text("Profile"),
                        ],
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 2,
                      child: Row(
                        children: [
                          Icon(Icons.settings_outlined),
                          SizedBox(width: 8),
                          Text("Settings"),
                        ],
                      ),
                    ),
                  ])
                ],
              ),
              body: Container(
                height: newScreenHeight,
                width: newScreenWidth,
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return ToggleButtons(
                          direction: Axis.horizontal,
                          onPressed: (int index) {
                            setState(() {
                              // The button that is tapped is set to true, and the others to false.
                              for (int i = 0; i < _selectedPermission.length; i++) {
                                _selectedPermission[i] = i == index;
                              }
                            });
                          },
                          borderWidth: 2,
                          borderRadius: const BorderRadius.all(Radius.circular(0)),
                          selectedBorderColor: Colors.green,
                          borderColor: Colors.green,
                          selectedColor: Colors.white,
                          fillColor: Colors.green[200],
                          constraints: BoxConstraints.expand(width: (constraints.maxWidth-6) / _selectedPermission.length),
                          // color: Colors.green[400],
                          // constraints: const BoxConstraints(
                          //   minHeight: 40.0,
                          //   minWidth: 200.0,
                          // ),
                          isSelected: _selectedPermission,
                          children: kPermission,
                        );
                      }
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          height: newScreenHeight-116,
                            child: (bruceUser.uid == 'Anonymous')
                                ? SignInMessage()
                                : _selectedPermission[1]  // 1=Public Tab
                                  ? GameListPublic()
                                  : Text("Build My Community Tab"),
                        ),
                      // const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Tooltip(
                                message: "Manage Messages",
                                child: TextButton.icon(
                                  icon: Icon(Icons.message_outlined),
                                  label: Text(""),
                                  onPressed: (bruceUser.uid == 'Anonymous')
                                      ? null
                                      : () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) =>
                                            MessageListIncoming(activePlayer: player)));
                                    //Navigator.pushNamed(context, '/message-list-incoming');
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Tooltip(
                                message: "Manage Memberships",
                                child: TextButton.icon(
                                  icon: Icon(Icons.games_rounded),
                                  label: Text(""),
                                  onPressed: (bruceUser.uid == 'Anonymous')
                                      ? null
                                      : () {
                                    Navigator.pushNamed(context, '/membership-list');
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Tooltip(
                                message: "Manage Communities",
                                child: TextButton.icon(
                                  icon: Icon(Icons.people_rounded),
                                  label: Text(""),
                                  onPressed: (bruceUser.uid == 'Anonymous')
                                      ? null
                                      : () {
                                    Navigator.pushNamed(context, '/community-list');
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      Text(
                        "Welcome '${bruceUser.displayName}' Verified = ${bruceUser.emailVerified ? 'Yes' : 'No'}",
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ]
                    ),
                    (kIsWeb) ? const SizedBox() : const AaBannerAd(),
                  ],
                ),
              ),
            ),
          );
          // } else {
          //   return const Loading();
          // }
        },
      ),
    );
  }

  void signOut() {
    final AuthService auth = AuthService();
    auth.signOut();
  }

  void signIn() {
    Navigator.pushNamed(context, '/authenticate');
  }

  // Helper Functions
  void onMenuSelected(BuildContext context, int item) {
    // final AuthService auth = AuthService();
    switch (item) {
      case 1:
        Navigator.of(context).push(
          // MaterialPageRoute(builder: (context) => const PlayerProfile()),
          MaterialPageRoute(builder: (context) => const PlayerProfilePage()),
        );
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => SettingsMain(player: player)),
        );
        break;
    }
  }
}