import 'dart:developer';
import 'package:flutter/material.dart';
// Status POPUP, Used for Games & Series Status.

enum StatusValues {prepare, active, complete, archived}
Map<StatusValues, String> statusValueText = {
  StatusValues.prepare: "Prepare",
  StatusValues.active: "Active",
  StatusValues.complete: "Complete",
  StatusValues.archived: "Archived",
};

class PopupMenuButtonStatus extends StatelessWidget {
  final void Function(StatusValues selectValue) onSelected;
  final StatusValues? initialValue;
  const PopupMenuButtonStatus({super.key, required this.onSelected, this.initialValue});


  @override
  Widget build(BuildContext context) {

    StatusValues currentStatus = initialValue ?? StatusValues.prepare;

    return PopupMenuButton<StatusValues>(
      tooltip: "Set Status",
      initialValue: initialValue,
      onSelected: (StatusValues selectedValue) {
        log("Value Selecteed", name: "${runtimeType.toString()}:build()");
        onSelected(selectedValue);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<StatusValues>>[
        const PopupMenuItem<StatusValues>(
          value: StatusValues.prepare,
          child: Text('Prep'),
        ),
        const PopupMenuItem<StatusValues>(
          value: StatusValues.active,
          child: Text('Active'),
        ),
        const PopupMenuItem<StatusValues>(
          value: StatusValues.complete,
          child: Text('Complete'),
        ),
        const PopupMenuItem<StatusValues>(
          value: StatusValues.archived,
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
