


import 'package:flutter/widgets.dart';
import 'package:mynotes/utils/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showDialogGeneric<bool>(
    context: context, 
    title: "Delete Note", 
    content: "Are you sure you want to delete this note.", 
    optionBuilder: () {
      return {
        "Cancel" : false,
        "Ok" : true,
      };
    }
  ).then((v) => v ?? false);
}