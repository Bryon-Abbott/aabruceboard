import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/database.dart';
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

  @override
  void initState() {
    series = widget.series;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //cid = ModalRoute.of(context)!.settings.arguments as String;
    BruceUser bruceUser = Provider.of<BruceUser>(context);
    String uid = bruceUser.uid;
    late String sid;

    String currentSeriesName = "";
    String currentSeriesType = "";
    int currentSeriesNoGames = 0;
    int noGames = 0;

    // Todo: Remove this
    if (series != null) {
      log('Got Series ${series!.name}');
    } else {
      log('No Series found ... New series, dont use until created?');
    }

    if ( series != null ) {
      //_sid = series.sid;
      currentSeriesName = series?.name ?? 'xxx';
      currentSeriesType = series?.type ?? 'xxx';
      currentSeriesNoGames = series?.noGames ?? 0;
    }
    // Build a Form widget using the _formGameKey created above.
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
//            backgroundColor: Colors.blue[900],
            title: Text((series != null ) ? 'Edit Series' : 'Add Series'),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: SingleChildScrollView(
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
                  const Text("Series Name: "),
                  TextFormField(
                    initialValue: currentSeriesName,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Series Name';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Game name is: $value');
                      currentSeriesName = value ?? 'Series 000';
                    },
                  ),
                  const Text("Type: "),
                  TextFormField(
                    initialValue: currentSeriesType,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter type';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Email is: $value');
                      currentSeriesType = value ?? 'auto-approve';
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Number of Games: ${series?.noGames ?? 'N/A'}"),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formSeriesKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              if ( series == null ) {
                                // Create new Series and store to Firebase
                                Map<String, dynamic> data =
                                { 'sid': -1,
                                  'name': currentSeriesName,
                                  'type': currentSeriesType,
                                  'noGames': currentSeriesNoGames,
                                };
                                series = Series( data: data ) ;
                                await DatabaseService(series!, uid: uid).fsDocAdd();
                                series?.noGames++;
                              } else {
                                // Update existing Series and store to Firebase
                                Map<String, dynamic> data =
                                { 'sid': -1,
                                  'name': currentSeriesName,
                                  'type': currentSeriesType,
                                  'noGames': currentSeriesNoGames,
                                };
                                series!.update(data: data);
                                // series!.name = currentSeriesName;
                                // series!.type = currentSeriesType;
                                // series!.noGames = currentSeriesNoGames;
                                await DatabaseService(series!, uid: uid).fsDocUpdate();
                              }
                              // Save Updates to Shared Preferences
                              log("series_maintain: Added/Updated series ${series?.noGames}");
                              Navigator.of(context).pop(series);
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: (series==null || series!.noGames > 0)
                                ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Must delete ALL games in series"),
                                )
                              );
                            }
                                : () {
                              if (series!.noGames == 0) {
                                // log('Delete Series ... ${_sid}');
                                log('Delete Series ... ${series!.key}');
                                DatabaseService(series!, uid: uid).fsDocDelete();
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text("Delete")),
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
          )
      ),
    );
  }
}