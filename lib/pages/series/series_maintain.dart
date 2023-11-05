import 'dart:developer';

import 'package:bruceboard/models/series.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    //cid = ModalRoute.of(context)!.settings.arguments as String;
    BruceUser bruceUser = Provider.of<BruceUser>(context);
    String _uid = bruceUser.uid;
    late String _sid;
//    Series series = Provider.of<Series>(context);
    Series? series = widget.series; ;
    String _currentSeriesName = "";
    String _currentSeriesType = "";
    int _currentSeriesNoGames = 0;
    int noGames = 0;

    // Todo: Remove this
    if (widget.series != null) {
      series = widget.series!;
      log('Got Series ${widget.series!.name}');
    } else {
      log('No Series found ... New series, dont use until created?');
    }

    if ( series != null ) {
      //_sid = series.sid;
      _currentSeriesName = widget.series?.name ?? 'xxx';
      _currentSeriesType = widget.series?.type ?? 'xxx';
      _currentSeriesNoGames = widget.series?.noGames ?? 0;
    }
    // Build a Form widget using the _formGameKey created above.
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
//            backgroundColor: Colors.blue[900],
            title: Text((widget.series != null ) ? 'Edit Series' : 'Add Series'),
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
                    initialValue: _currentSeriesName,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Series Name';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Game name is: $value');
                      _currentSeriesName = value ?? 'Series 000';
                    },
                  ),
                  const Text("Type: "),
                  TextFormField(
                    initialValue: _currentSeriesType,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter type';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Email is: $value');
                      _currentSeriesType = value ?? 'auto-approve';
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
                              if ( widget.series == null ) {
                                // Add new Game
                                Map<String, dynamic> data =
                                { 'sid': -1,
                                  'name': _currentSeriesName,
                                  'type': _currentSeriesType,
                                  'noGames': _currentSeriesNoGames,
                                };
                                await DatabaseService(uid: _uid).addSeries(
                                  series: Series( data: data ),
                                );
                                widget.series?.noGames++;
                              } else {
                                // update existing game
                                // await DatabaseService(uid: _uid).updateSeries(
                                //   sid: widget.series?.sid ?? 'S9999',
                                //   name: _currentSeriesName,
                                //   type: _currentSeriesType,
                                //   noGames: _currentSeriesNoGames,
                                // );
                                await DatabaseService(uid: _uid).updateSeries(
                                  series: widget.series!,
                                );
                              }
                              // Save Updates to Shared Preferences
                              log("series_maintain: Added/Updated series "
                                  "${widget.series?.noGames}");
                              Navigator.of(context).pop(widget.series);
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: (series==null || series.noGames > 0)
                                ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Must delete ALL games in series"),
                                )
                              );
                            }
                                : () {
                              if (series!.noGames == 0) {
                                // log('Delete Series ... ${_sid}');
                                log('Delete Series ... ${series.key}');
                                DatabaseService(uid: _uid).deleteSeries(series.key);
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