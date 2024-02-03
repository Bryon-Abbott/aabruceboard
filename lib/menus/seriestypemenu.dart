import 'package:flutter/material.dart';

/// Flutter code sample for [PopupMenuButton].

// This is the type used by the popup menu below.
enum SeriesTypeItem { itemNFL, itemCFL, itemNBA, itemOther }

class PopupMenuSeriesType extends StatefulWidget {
  const PopupMenuSeriesType({super.key});

  @override
  State<PopupMenuSeriesType> createState() => _PopupMenuSeriesTypeState();
}

class _PopupMenuSeriesTypeState extends State<PopupMenuSeriesType> {
  SeriesTypeItem? selectedMenu;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Series Type')),
      body: Center(
        child: PopupMenuButton<SeriesTypeItem>(
          initialValue: selectedMenu,
          // Callback that sets the selected popup menu item.
          onSelected: (SeriesTypeItem item) {
            setState(() {
              selectedMenu = item;
            });
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<SeriesTypeItem>>[
            const PopupMenuItem<SeriesTypeItem>(
              value: SeriesTypeItem.itemNFL,
              child: Text('NFL'),
            ),
            const PopupMenuItem<SeriesTypeItem>(
              value: SeriesTypeItem.itemCFL,
              child: Text('CFL'),
            ),
            const PopupMenuItem<SeriesTypeItem>(
              value: SeriesTypeItem.itemNBA,
              child: Text('NBA'),
            ),
            const PopupMenuItem<SeriesTypeItem>(
              value: SeriesTypeItem.itemOther,
              child: Text('Other'),
            ),
          ],
        ),
      ),
    );
  }
}
