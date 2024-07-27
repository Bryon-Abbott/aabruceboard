import 'package:flutter/material.dart';

Widget addVerticalSpace(double height){
  return SizedBox(
    height: height,
  );
}

Widget addHorizontalSpace(double width){
  return SizedBox(
    width: width,
  );
}
// ===========================================================================
// Dialog to get user Text for Messages.
Future<String?> openDialogMessageComment(BuildContext context, {String? defaultComment, String? defaultTitle}) {
  TextEditingController controller1 = TextEditingController( text: defaultComment);
  return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(6,2,2,2),
        actionsPadding: const EdgeInsets.all(2),
        contentPadding: const EdgeInsets.fromLTRB(6,2,6,2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0)
        ),
      title: Text("${defaultTitle ?? 'Message Text'}"),
      titleTextStyle: Theme.of(context).textTheme.bodyLarge,
      contentTextStyle: Theme.of(context).textTheme.bodyLarge,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Add text to message ...'),
            style: Theme.of(context).textTheme.bodyMedium,
            controller: controller1,
            onSubmitted: (_) {
              Navigator.of(context).pop(controller1.text);
              controller1.clear();
            }
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(controller1.text);
            controller1.clear();
            },
          child: const Text('Send'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
            controller1.clear();
          },
          child: const Text('Cancel'),
        ),
      ],
    )
  );
}
