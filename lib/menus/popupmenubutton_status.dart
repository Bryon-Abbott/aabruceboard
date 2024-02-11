import 'dart:developer';
import 'package:flutter/material.dart';
// Status POPUP, Used for Games & Series Status.

enum StatusValues {Prepare, Active, Complete, Archived}
Map<StatusValues, String> statusValueText = {
  StatusValues.Prepare: "Prepare",
  StatusValues.Active: "Active",
  StatusValues.Complete: "Complete",
  StatusValues.Archived: "Archived",
};

class PopupMenuButtonStatus extends StatelessWidget {
  final void Function(StatusValues selectValue) onSelected;
  StatusValues? initialValue;
  PopupMenuButtonStatus({super.key, required this.onSelected, this.initialValue});


  @override
  Widget build(BuildContext context) {

    StatusValues currentStatus = initialValue ?? StatusValues.Prepare;

    return PopupMenuButton<StatusValues>(
      tooltip: "Set Status",
      initialValue: initialValue,
      onSelected: (StatusValues selectedValue) {
        log("Value Selecteed", name: "${runtimeType.toString()}:build()");
        onSelected(selectedValue);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<StatusValues>>[
        const PopupMenuItem<StatusValues>(
          value: StatusValues.Prepare,
          child: Text('Prep'),
        ),
        const PopupMenuItem<StatusValues>(
          value: StatusValues.Active,
          child: Text('Active'),
        ),
        const PopupMenuItem<StatusValues>(
          value: StatusValues.Complete,
          child: Text('Complete'),
        ),
        const PopupMenuItem<StatusValues>(
          value: StatusValues.Archived,
          child: Text('Archive'),
        ),
      ],
      child: ListTile(
        leading: const Icon(Icons.punch_clock_outlined),
        trailing: const Icon(Icons.menu),
        title: Text("Status: ${currentStatus.index}:${statusValueText[currentStatus]} "),
      ),
    );
  }
}
