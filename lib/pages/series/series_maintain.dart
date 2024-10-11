import 'dart:developer';
import 'package:bruceboard/menus/popupmenubutton_status.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/utils/banner_ad.dart';
import 'package:bruceboard/utils/league_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/pages/access/access_list.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
// Sports by Becris from <a href="https://thenounproject.com/browse/icons/term/sports/" target="_blank" title="Sports Icons">Noun Project</a> (CC BY 3.0)

// Create a Form widget.
class SeriesMaintain extends StatefulWidget {
  final Series? series;
  const SeriesMaintain({super.key, this.series});

  @override
  SeriesMaintainState createState() => SeriesMaintainState();
}

class SeriesMaintainState extends State<SeriesMaintain> {
  final _formSeriesKey = GlobalKey<FormState>();
  late Series? series;
  Player? player;
  late BruceUser bruceUser;

  String currentSeriesType = "Other";
  String currentSeriesPng = "assets/noun-sports-1176751.png";
  int currentStatus = 0;
  Icon currentSeriesIcon = const Icon(Icons.cabin_outlined);
  String currentSeriesName = "";
  int currentSeriesNoGames = 0;
  int currentDefaultCid = -1;
  late TextEditingController controllerCid;

  @override
  void initState() {
    series = widget.series;
    // BruceUser bruceUser = Provider.of<BruceUser>(context);
    if ( series != null ) {
      currentSeriesName = series?.name ?? 'xxx';
      currentSeriesType = series?.type ?? 'xxx';
      currentSeriesNoGames = series?.noGames ?? 0;
      currentStatus = series?.status ?? 0;
      currentDefaultCid = series?.defaultCid ?? -1;
      SeriesType sti = seriesData.keys.firstWhere((k) => seriesData[k]?.seriesText == currentSeriesType,
          orElse: () =>  SeriesType.itemOther);
     // currentSeriesPng = seriesTypeData[sti]![1];
      currentSeriesIcon = seriesData[sti]!.seriesIcon;
    }    super.initState();
    controllerCid = TextEditingController(text: Community.Key(series?.defaultCid ?? 99999));
  }

  @override
  void dispose() {
    controllerCid.dispose(); // Dispose of TextEditingController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //cid = ModalRoute.of(context)!.settings.arguments as String;
    bruceUser = Provider.of<BruceUser>(context);
    log('Current User:  ${bruceUser.uid}', name: '${runtimeType.toString()}:build()');
    String uid = bruceUser.uid;
//    late String sid;

//    int noGames = 0;

    // Todo: Remove this
    if (series != null) {
      log('Got Series ${series!.name}', name: '${runtimeType.toString()}:build()');
    } else {
      log('No Series found ... New series, dont use until created?', name: '${runtimeType.toString()}:build()');
    }

    // Build a Form widget using the _formGameKey created above.
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
//            backgroundColor: Colors.blue[900],
            title: Text((series != null ) ? 'Edit Group' : 'Add Group'),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    //autovalidateMode: AutovalidateMode.always,
                    onChanged: () {
                      //debugPrint("Something Changed ... Game '$game' Email '$email' ");
                      Form.of(primaryFocus!.context!).save();
                    },
                    key: _formSeriesKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Type: "),
                        PopupMenuButton<SeriesType>(
                          tooltip: "Select League",
                          initialValue: seriesData.keys.firstWhere((k) => seriesData[k]?.seriesText == currentSeriesType,
                                                            orElse: () =>  SeriesType.itemOther),  //currentSeriesType,
                          // Callback that sets the selected popup menu item.
                          onSelected: (SeriesType item) {
                            setState(() {
                              currentSeriesType = seriesData[item]!.seriesText;
                              currentSeriesIcon = seriesData[item]!.seriesIcon;
                              log("Current Group Type: '$item' Text: ${seriesData[item]!.seriesText} Current: $currentSeriesType", name: '${runtimeType.toString()}:build()');
                            });
                            // currentSeriesType = seriesTypeText[item]!;
                            // log("Current Series Type: '$item' Text: ${seriesTypeText[item]} Current: ${currentSeriesType}", name: '${runtimeType.toString()}:build()');
                          },
                          itemBuilder: (BuildContext context) {
                            List<PopupMenuEntry<SeriesType>> menuItems = <PopupMenuEntry<SeriesType>>[];

                            for (SeriesType e in SeriesType.values ) {
                              menuItems.add(PopupMenuItem<SeriesType>(
                                  value: e,
                                  child: Text(seriesData[e]!.seriesText)));
                            }
                            return menuItems;
                          } ,
                          child: ListTile(
                            leading: currentSeriesIcon,
                            trailing: const Icon(Icons.menu),
                            title: Text("Type: $currentSeriesType"),
                          ),
                        ),
                        const Text("Group Name: "),
                        TextFormField(
                          initialValue: currentSeriesName,
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Group Name';
                            }
                            return null;
                          },
                          onSaved: (String? value) {
                            //debugPrint('Game name is: $value');
                            currentSeriesName = value ?? 'Series 000';
                          },
                        ),
                        const Text("Default Community"),
                        Row(
                          children: [
                            Expanded(
                            //  width: 100,
                              child: TextFormField(
                                controller: controllerCid,
                                readOnly: true,
                                // initialValue: Community.Key(currentDefaultCid),
                                validator: (value) {
                                  if (value == null || value.isEmpty || value == '-C0001') {
                                    return 'Please select a default community';
                                  }
                                  return null;
                                },
                                onSaved: (String? value) {
                                  currentDefaultCid =  (value != null) ? int.parse(value) : -1;
                                },
                              ),
                            ),
                            // Spacer(),
                            ElevatedButton(
                                onPressed: () async {
                                  Community? community;
                                  dynamic results = await Navigator.pushNamed(context, '/community-select-owner');
                                  if (results != null) {
                                    community = results[1] as Community;
                                    controllerCid.text = Community.Key(community.docId);
                                    currentDefaultCid = community.docId;
                                    log("Got Community Value ${community.docId}",name: '${runtimeType.toString()}:build()' );
                                    setState(() {  });
                                    }
                                  },
                                child: const Text("Pick")),
                          ]
                        ),

                        const Text("Group Status"),
                        PopupMenuButtonStatus(
                          initialValue: StatusValues.values[currentStatus],
                          // initialValue: StatusValues.Prepare,
                          onSelected: (StatusValues selectValue) {
                            log("Got Selected Value ${selectValue.index} ${selectValue.name}",name: '${runtimeType.toString()}:build()' );
                            setState(() {
                              currentStatus = selectValue.index;
                            });
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Number of Boards: ${series?.noGames ?? 'N/A'}, Number of Community Accesses ${series?.noAccesses ?? 0}"),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                child: const Text('Save'),
                                onPressed: () async {
                                  // Validate returns true if the form is valid, or false otherwise.
                                  if (player == null) {
                                    log('Getting Player ... ', name: '${runtimeType.toString()}:build()');
                                    FirestoreDoc? fsDoc = await DatabaseService(FSDocType.player).fsDoc(key: bruceUser.uid);
                                    if (fsDoc != null) {
                                      player = fsDoc as Player;
                                    } else {
                                      log('Waiting for Player', name: '${runtimeType.toString()}:build()');
                                    }
                                  }
                                  log('Player is ... ${player!.fName}', name: '${runtimeType.toString()}:build()');
                                  if (_formSeriesKey.currentState!.validate()) {
                                    // If the form is valid, display a snackbar. In the real world,
                                    // you'd often call a server or save the information in a database.
                                    if ( series == null ) {
                                      // Create new Series and store to Firebase
                                      Map<String, dynamic> data =
                                      { 'pid': player!.pid,
                                        'name': currentSeriesName,
                                        'type': currentSeriesType,
                                        'status': currentStatus,
                                        'defaultCid': currentDefaultCid,
                                        'noGames': currentSeriesNoGames,
                                      };
                                      series = Series( data: data );
                                      await DatabaseService(FSDocType.series, uid: uid).fsDocAdd(series!);
                                      // series!.sid = series!.docId; // Set SID to docID
                                      // await DatabaseService(FSDocType.series, uid: uid).fsDocUpdate(series!);
                                      //series?.noGames++;
                                    } else {
                                      // Update existing Series and store to Firebase
                                      Map<String, dynamic> data =
                                      { 'name': currentSeriesName,
                                        'type': currentSeriesType,
                                        'status': currentStatus,
                                        'defaultCid': currentDefaultCid,
                                        'noGames': currentSeriesNoGames,  // Todo: Delete this and let default? Add noAccesses?
                                      };
                                      series!.update(data: data);
                                      // series!.name = currentSeriesName;
                                      // series!.type = currentSeriesType;
                                      // series!.noGames = currentSeriesNoGames;
                                      await DatabaseService(FSDocType.series, uid: uid).fsDocUpdate(series!);
                                    }
                                    // Save Updates to Shared Preferences
                                    log("Added/Updated series ${series?.noGames}", name: '${runtimeType.toString()}:build()');
                                    if (!context.mounted) return;
                                    Navigator.of(context).pop(series);
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (series==null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Series not saved ..."),
                                      )
                                    );
                                  } else if (series!.noGames > 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Must delete ALL games in series ..."),
                                      )
                                    );
                                  } else if (series!.noAccesses > 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Must delete ALL access in series ..."),
                                        )
                                    );
                                  } else {
                                    // log('Delete Series ... ${_sid}');
                                    log('Delete Series ... ${series!.key}', name: '${runtimeType.toString()}:build()');
                                    DatabaseService(FSDocType.series, uid: uid).fsDocDelete(series!);
                                    Navigator.of(context).pop();

                                  }
                                },
                                  child: const Text("Delete")),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                  onPressed: (series==null) ? null : () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => AccessList(series: series!)),
                                    );
                                    series = await DatabaseService(FSDocType.series).fsDoc(key: series!.key) as Series;
                                    setState(() {
                                      log('setting State: ${series!.noAccesses}', name: '${runtimeType.toString()}:build()');
                                    });
                                  log('Back from AccessList, No Access ${series!.noAccesses}', name: '${runtimeType.toString()}:build()');
                                  },
                                  child: const Text("Access")),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                  onPressed: () {
                                    if (kDebugMode) {
                                      print("Return without adding series");
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel")),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const AdContainer(),
//              (kIsWeb) ? const SizedBox() : const AaBannerAd(),
            ],
          )
      ),
    );
  }
}