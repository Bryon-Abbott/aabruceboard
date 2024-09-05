import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/utils/preferences.dart';

// ==========
// Desc: Create Settings() class to store and manage settings
// ----------
// 2023/08/20 Bryon   Created
// ==========
class SettingsMain extends StatefulWidget {
  const SettingsMain({super.key, required this.player});
  final Player player;

  @override
  State<SettingsMain> createState() => _SettingsMainState();
}

class _SettingsMainState extends State<SettingsMain> {
//  _SettingsMainState({required this.player})
  late Player player;
  bool settingDarkMode = false;
  bool settingNewInterface = false;

  @override
  void initState() {
    super.initState();
    player = widget.player;
    settingNewInterface = Preferences.getPreferenceBool(Preferences.keyNewInterface) ?? false;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // if user presses back, cancels changes to list (order/deletes)
          onPressed: () {
            Navigator.of(context).pop();
            if (settingNewInterface) {
              Navigator.of(context).pushReplacementNamed('/home2');
            } else {
              Navigator.of(context).pushReplacementNamed('/home1');
            }
          },
        ),        title: Text('Settings for ${widget.player.lName}'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                Preferences.removePreferences(Preferences.keyALL);
                Navigator.pop(context);
              });
            },
            icon: const Icon(Icons.clear_all),
            tooltip: "Clear ALL Settings and return ...",
          ),
        ],
      ),
      body: SafeArea(
        child: SettingsList(
          contentPadding: const EdgeInsets.all(20),
          platform: DevicePlatform.android,
          sections: [
            SettingsSection(
                title: const Text('General'),
                tiles: [
                  SettingsTile.switchTile(
                    enabled: true,
                    leading: const Icon(Icons.dark_mode_outlined),
                    // initialValue: false,
                    initialValue: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark,
                    // onToggle: (enable) {},
                    onToggle: (enable) {
                      if (enable) {
                        AdaptiveTheme.of(context).setDark();
                      } else {
                        AdaptiveTheme.of(context).setLight();
                      }
                    },
                    title: const Text("Dark Mode"),
                  ),
                  SettingsTile.switchTile(
                    leading: const Icon(Icons.new_releases_outlined),
                    initialValue: settingNewInterface,
                    onToggle: (enable) {
                      settingNewInterface = enable;
                      Preferences.setPreferenceBool(Preferences.keyNewInterface, settingNewInterface);
                      setState(() {
                      });
                    },
                    title: const Text("Test New Interface"),
                  ),
                ]
            ),
            SettingsSection(
                title: const Text('Auto Processing'),
                tiles: [
                  SettingsTile.switchTile(
                    enabled: false,
                    leading: const Icon(Icons.check_circle_outline),
                    // initialValue: false,
                    initialValue: player.autoProcessNot,
                    // onToggle: (enable) {},
                    onToggle: (enable) async {
                      await DatabaseService(FSDocType.player)
                          .fsDocUpdateField(key: player.uid, field: 'autoProcessNot', bvalue: enable);
                      setState(() {
                        player.update(data: {'autoProcessNot': enable});
                      });
                    },
                    title: const Text("Notifications"),
                  ),
                  SettingsTile.switchTile(
                    enabled: true,
                    leading: const Icon(Icons.check_circle_outline),
                    // initialValue: false,
                    initialValue: player.autoProcessAck,
                    // onToggle: (enable) {},
                    onToggle: (enable) async {
                      await DatabaseService(FSDocType.player)
                          .fsDocUpdateField(key: player.uid, field: 'autoProcessAck', bvalue: enable);
                      setState(() {
                        player.update(data: {'autoProcessAck': enable});
                      });
                    },
                    title: const Text("Acknowledgements"),
                  ),
                  SettingsTile.switchTile(
                    enabled: true,
                    leading: const Icon(Icons.check_circle_outline),
                    // initialValue: false,
                    initialValue: player.autoProcessAcc,
                    // onToggle: (enable) {},
                    onToggle: (enable) async {
                      await DatabaseService(FSDocType.player)
                          .fsDocUpdateField(key: player.uid, field: 'autoProcessAcc', bvalue: enable);
                      setState(() {
                        player.update(data: {'autoProcessAcc': enable});
                      });

                    },
                    title: const Text("Acceptances"),
                  ),
                  SettingsTile.switchTile(
                    enabled: true,
                    leading: const Icon(Icons.check_circle_outline),
                    // initialValue: false,
                    initialValue: player.autoProcessReq,
                    // onToggle: (enable) {},
                    onToggle: (enable) async {
                      await DatabaseService(FSDocType.player)
                          .fsDocUpdateField(key: player.uid, field: 'autoProcessReq', bvalue: enable);
                      setState(() {
                        player.update(data: {'autoProcessReq': enable});
                      });

                    },
                    title: const Text("Square Requests"),
                  ),
                ]
            ),
          ],
        ),
      ),
    );
  }
}

