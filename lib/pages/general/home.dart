import 'dart:developer';
import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/pages/message/message_list_incoming.dart';
import 'package:bruceboard/pages/player/player_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/theme/theme_manager.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/communityplayerprovider.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/services/auth.dart';
import 'package:bruceboard/pages/settings/settings_main.dart';

// ==========
// Desc: Load home screen
// ----------
// 2023/09/12 Bryon   Created
// ==========
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //late Future<Player> _futurePlayer;
  late CommunityPlayerProvider communityPlayerProvider; // = Provider.of<CommunityPlayerProvider>(context);
  late ActivePlayerProvider activePlayerProvider; // = Provider.of<ActivePlayerProvider>(context);
  late Player player;

  @override
  void dispose() {
    themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    themeManager.addListener(themeListener);
    // communityPlayerProvider = CommunityPlayerProvider();
    // activePlayerProvider = ActivePlayerProvider();
    //Preferences.setDarkMode(true);
    // bool settingDarkMode = Preferences.getDarkMode() ?? false;
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final BruceUser bruceUser = Provider.of<BruceUser?>(context) ?? BruceUser();
    log('Start of Build: ${bruceUser.uid} ${bruceUser.displayName}', name: "${runtimeType.toString()}:build()");

    communityPlayerProvider = Provider.of<CommunityPlayerProvider>(context);
    activePlayerProvider = Provider.of<ActivePlayerProvider>(context);
    // late Player player;

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
          log('Pre-Community UID: ${communityPlayerProvider.communityPlayer.uid} ${communityPlayerProvider.communityPlayer.fName}',
              name: "${runtimeType.toString()}:build()");
          log('Pre-Active UID: ${activePlayerProvider.activePlayer.uid} ${activePlayerProvider.activePlayer.fName}',
              name: "${runtimeType.toString()}:build()");
          // Default communityPlayer if not set yet
          if (snapshot.hasData) {
            log('Got Document with docId ${snapshot.data!.docId} and Type: ${snapshot.data.runtimeType}', name: "${runtimeType.toString()}:build()");
            if (snapshot.data!.docId != -1) {
              player = snapshot.data as Player;
              log('Got Player ${player.fName}', name: "${runtimeType.toString()}:build()");
              activePlayerProvider.activePlayer = player;
              if (communityPlayerProvider.communityPlayer.uid == 'Anonymous') {
                communityPlayerProvider.communityPlayer = player;
              }
            } else {
              log('No Player ... set to  Providers to Anonymous.', name: "${runtimeType.toString()}:build()");
              activePlayerProvider.activePlayer = Player(data: {});
              communityPlayerProvider.communityPlayer = Player(data: {});
            }
          }
          log('Post-Community Owner UID: ${communityPlayerProvider.communityPlayer.uid} ${communityPlayerProvider.communityPlayer.fName}',
              name: "${runtimeType.toString()}:build()");
          log('Post-Active UID: ${activePlayerProvider.activePlayer.uid} ${activePlayerProvider.activePlayer.fName}',
              name: "${runtimeType.toString()}:build()");
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
                  PopupMenuButton<int>(
                      //              color: Colors.blue,
                      onSelected: (item) => onMenuSelected(context, item),
                      itemBuilder: (context) => [
                            const PopupMenuItem<int>(
                              value: 0,
                              child: Row(
                                children: [
                                  Icon(Icons.logout_outlined),
                                  SizedBox(width: 8),
                                  Text("Sign Out"),
                                ],
                              ),
                            ),
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
                            const PopupMenuDivider(),
                            const PopupMenuItem<int>(
                                value: 3,
                                child: Row(children: [
                                  Icon(Icons.logout),
                                  SizedBox(width: 8),
                                  Text("Exit"),
                                ])),
                          ])
                ],
              ),
              body: SafeArea(
                child: Container(
                  height: newScreenHeight,
                  width: newScreenWidth,
                  color: Theme.of(context).colorScheme.surface,
                  child: SingleChildScrollView(
                    child: Column(children: <Widget>[
                      const SizedBox(height: 20,),
                      // Text(
                      //   'Welcome',
                      //   textAlign: TextAlign.center,
                      //   style: Theme.of(context).textTheme.displayLarge,
                      // ),
                      Text(
                        'BruceBoard Squares',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      Text(
                        'a Football Pool App',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 260,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.green[800]!),
                                  ),
                                  //padding: const EdgeInsets.all(8.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text("Play Games",
                                          style: Theme.of(context).textTheme.titleMedium,),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton.icon(
                                            onPressed: (bruceUser.uid == 'Anonymous')
                                                ? null
                                                : () {
                                              Navigator.pushNamed(
                                                  context, '/membership-list');
                                            },
                                            icon: Icon(
                                              Icons.collections_outlined,
                                              size: 32,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.color ??
                                                  Colors.red,
                                            ),
                                            label: Text('Join Communities & Play Games',
                                              style:
                                              Theme.of(context).textTheme.titleMedium,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton.icon(
                                            onPressed: (bruceUser.uid == 'Anonymous')
                                                ? null
                                                : () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(builder: (context) => MessageListIncoming(activePlayer: player)));
                                              //Navigator.pushNamed(context, '/message-list-incoming');
                                            },
                                            icon: Icon(
                                              Icons.message_outlined,
                                              size: 32,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.color ??
                                                  Colors.red,
                                            ),
                                            label: Text('View & Respond to Messages',
                                              style: Theme.of(context).textTheme.titleMedium,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8,),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.green[800]!),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Text("Run Games",
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ElevatedButton.icon(
                                              onPressed: (bruceUser.uid == 'Anonymous')
                                                  ? null
                                                  : () {
                                                Navigator.pushNamed(
                                                    context, '/community-list');
                                              },
                                              icon: Icon(
                                                Icons.person,
                                                size: 32,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.color ??
                                                    Colors.red,
                                              ),
                                              label: Text(
                                                'Create & Edit Communities',
                                                style:
                                                Theme.of(context).textTheme.titleMedium,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ElevatedButton.icon(
                                              onPressed: (bruceUser.uid == 'Anonymous')
                                                  ? null
                                                  : () {
                                                Navigator.pushNamed(
                                                  //  context, '/manageplayers', arguments: BruceArguments(players, games));
                                                    context,
                                                    '/series-list');
                                              },
                                              icon: Icon(
                                                Icons.sports_football_outlined,
                                                size: 32,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.color ??
                                                    Colors.red,
                                              ),
                                              label: Text(
                                                'Create Groups & Manage Games',
                                                style:
                                                Theme.of(context).textTheme.titleMedium,
                                              ),
                                            ),
                                          ),
      
                                        ]
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: ElevatedButton.icon(
                                    onPressed: (bruceUser.uid != 'Anonymous')
                                        ? null
                                        : () {
                                            Navigator.pushNamed(
                                                //  context, '/managegames', arguments: BruceArguments(players, games));
                                                context,
                                                '/authenticate');
                                          },
                                    icon: Icon(
                                      Icons.login,
                                      size: 32,
                                      color: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.color ??
                                          Colors.red,
                                    ),
                                    label: Text(
                                      'Sign In',
                                      style:
                                          Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/about');
                                    },
                                    icon: Icon(
                                      Icons.question_mark,
                                      size: 32,
                                      color: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.color ??
                                          Colors.red,
                                    ),
                                    label: Text(
                                      'About',
                                      style:
                                          Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8.0),
      //                     const Padding(
      //                       padding: EdgeInsets.all(8.0),
      //                       child: SizedBox(
      //                         height: 150,
      //                         width: 300,
      //                         child: Image(
      //                           image: AssetImage(
      //                               'assets/AdobeStock_118223983.jpeg'),
      // //                              'assets/AdobeStock_55757786-horizontal-bw.jpeg'),
      //                         ),
      //                       ),
      //                     ),
                      Text("... Enjoy ...",
                        // data['time'],
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      // Spacer(),
                      const SizedBox(height: 20.0),
                      Text(
                        "Welcome '${bruceUser.displayName}' Verified = ${bruceUser.emailVerified ? 'Yes' : 'No'}",
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ]),
                  ),
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

// Helper Functions
  void onMenuSelected(BuildContext context, int item) {
    final AuthService auth = AuthService();
    switch (item) {
      case 0:
        // log('Reset Provider Players to Anonymous and Sign Out', name: "${runtimeType.toString()}:onMenuSelected()");
        // communityPlayerProvider.communityPlayer = Player(data: {});
        // activePlayerProvider.activePlayer = Player(data: {});
        auth.signOut();
        break;
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
      case 3:
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        break;
    }
  }
}

