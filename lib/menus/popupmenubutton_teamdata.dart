import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:bruceboard/flutter_any_logo/league_list.dart';

class PopupMenuButtonTeamData extends StatelessWidget {
  final void Function(TeamData selectedValue) onSelected;
  final TeamData initialValue;
  final String? toolTip;
  final Map<String, TeamData> leagueTeamData;

  const PopupMenuButtonTeamData({super.key,
    required this.onSelected,
    required this.initialValue,
    required this.leagueTeamData,
    this.toolTip
  });

  @override
  Widget build(BuildContext context) {

    TeamData currentTeamData = initialValue;

    return PopupMenuButton<TeamData>(
      tooltip: toolTip,
      initialValue: initialValue,
      onSelected: (TeamData selectedValue) {
        log("Team Selected: ${selectedValue.teamCity}, ${selectedValue.teamName}");
        onSelected(selectedValue);
      },
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<TeamData>> menuItems = <PopupMenuEntry<TeamData>>[];

        for (TeamData m in leagueTeamData.values ) {
          menuItems.add(PopupMenuItem<TeamData>(
            value: m,
            child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image(image: AssetImage(leagueTeamData[m.teamKey]!.teamLogo.path), height: 50, width: 50,),
                  ),
                  Text("${leagueTeamData[m.teamKey]!.teamCity} ${leagueTeamData[m.teamKey]!.teamName}"),
                ]
            ),
          ));
        }
        return menuItems;
      },
      child: ListTile(
        leading: (leagueTeamData[currentTeamData.teamKey] != null)
            ? Image(image: AssetImage(leagueTeamData[currentTeamData.teamKey]!.teamLogo.path))
            : const Icon(Icons.info_outline),
        trailing: const Icon(Icons.menu),
        title: (leagueTeamData[currentTeamData.teamKey] != null)
            ? Text("${leagueTeamData[currentTeamData.teamKey]!.teamCity} ${leagueTeamData[currentTeamData.teamKey]!.teamName}")
            : const Text("Select Team"),
      ),
    );
  }
}
