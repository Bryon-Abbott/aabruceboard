import 'package:adaptive_theme/adaptive_theme.dart';
//import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:bruceboard/utils/icon_widget.dart';
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
  bool autoProcessNot = false,
      autoProcessAck = false,
      autoProcessReq = false;

  @override
  void initState() {
    super.initState();
    player = widget.player;
    //    settingDarkMode = Preferences.getDarkMode() ?? false;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings for ${widget.player.lName}'),
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
          contentPadding: const EdgeInsets.all(24),
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
                  SettingsTile(
                    enabled: true,
                    leading: const Icon(Icons.not_interested_outlined),
                    // initialValue: false,
                    title: const Text("Exclude Player"),
                    trailing: const IntegerFormField(
                      sharedPreferenceKey: Preferences.keyExcludePlayerNo,
                      initialValue: '00000',
                    ),
                  ),
                ]
            ),
            SettingsSection(
                title: const Text('Auto Processing'),
                tiles: [
                  SettingsTile.switchTile(
                    // enabled: true,
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
                    initialValue: player.autoProcessReq,
                    // onToggle: (enable) {},
                    onToggle: (enable) async {
                      await DatabaseService(FSDocType.player)
                          .fsDocUpdateField(key: player.uid, field: 'autoProcessReq', bvalue: enable);
                      setState(() {
                        player.update(data: {'autoProcessReq': enable});
                      });

                    },
                    title: const Text("Requests"),
                  ),
                ]
            ),
          ],
        ),
      ),
    );
  }
}

