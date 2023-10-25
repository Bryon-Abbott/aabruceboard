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
//    Series series = Provider.of<Series>(context);

    String _currentSeriesName = "";
    String _currentSeriesType = "";
    int noGames = 0;

    if (widget.series != null) {
      log('Got Series ${widget.series!.name}');
    } else {
      log('No Series found');
    }

    if ( widget.series != null ) {
      _currentSeriesName = widget.series?.name ?? 'xxx';
      _currentSeriesType = widget.series?.type ?? 'xxx';
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
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          onPressed: () async {
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formSeriesKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              if ( widget.series == null ) {
                                // Add new Game
                                await DatabaseService(pid: bruceUser.uid).addSeries(
                                    name: _currentSeriesName,
                                    type: _currentSeriesType,
                                );
                              } else {
                                // update existing game
                                await DatabaseService(pid: bruceUser.uid).updateSeries(
                                  sid: widget.series?.sid ?? 'Error',
                                  name: _currentSeriesName,
                                  type: _currentSeriesType,
                                );                              }
                              // Save Updates to Shared Preferences
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Save'),
                        ),
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