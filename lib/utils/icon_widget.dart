import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bruceboard/utils/preferences.dart';

class IntegerFormField extends StatefulWidget {

  final String initialValue;
  final String sharedPreferenceKey;

  const IntegerFormField({required this.initialValue, required this.sharedPreferenceKey, super.key});

  @override
  State<IntegerFormField> createState() => _IntegerFormFieldState();
}

class _IntegerFormFieldState extends State<IntegerFormField> {
  String? initialValue;
//  String? sharedPreferenceKey;

  bool updateDisabled = true;
  String newValue = '99999';
  String currentValue = '99999';

  @override
  void initState() {
    super.initState();

    String? tempValue = Preferences.getPreferenceString(widget.sharedPreferenceKey);
    if (tempValue == null) {
      currentValue = widget.initialValue;
      Preferences.setPreferenceString(widget.sharedPreferenceKey, currentValue);
    } else {
      currentValue = tempValue;
    }
    newValue = currentValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          height: 40,
          child: TextFormField(
            style: Theme.of(context).textTheme.bodySmall,
            initialValue: currentValue,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              hintText: '99999',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              LengthLimitingTextInputFormatter(5),
            ],
            onChanged: (String? value) {
              newValue = value ?? '';
              if (updateDisabled) {
                updateDisabled = false;
                setState(() {});
              }
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.update),
          color: Colors.green,
          disabledColor: Colors.grey,
          onPressed: updateDisabled ? null
            : () {
            setState(() {
              if (newValue == '') {
                newValue = initialValue ?? '0';
              }
              currentValue = newValue;
              updateDisabled = true;
              Preferences.setPreferenceString(widget.sharedPreferenceKey, newValue);
            });
            },
        )
      ],
    );
  }
}

