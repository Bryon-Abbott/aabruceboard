import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:bruceboard/utils/icon_widget.dart';
import 'package:bruceboard/utils/preferences.dart';


// ==========
// Desc: Create Settings() class to store and manage settings
// ----------
// 2023/08/20 Bryon   Created
// ==========
class SettingsMain extends StatefulWidget {
  const SettingsMain({super.key});

  @override
  State<SettingsMain> createState() => _SettingsMainState();
}

class _SettingsMainState extends State<SettingsMain> {
  bool settingDarkMode = false;

  @override
  void initState() {
    super.initState();
//    settingDarkMode = Preferences.getDarkMode() ?? false;
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Settings'),
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
          SettingsSection(title: const Text('General'), tiles: [
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
                initialValue: '0000',
              ),
            ),
            SettingsTile.navigation(
                title: const Text('Scoring Settings'),
                leading: const Icon(Icons.scoreboard),
                trailing: const Icon(Icons.navigate_next),
                onPressed: (context) {
                  Navigator.pushNamed(context, '/settings_scoring');
                }),
          ]),
        ],
      ),
    ),
  );
}

