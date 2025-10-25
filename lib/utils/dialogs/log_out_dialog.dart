
import 'package:flutter/material.dart';
import 'package:mynotes/utils/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialogGeneric<bool>(
    context: context, 
    title: 'Log Out', 
    content: 'Are you sure , do you want to logout.', 
    optionBuilder: () {
      return {
        'Cancel' : false,
        'Log out' : true
      };
    }
  ).then((v) => v ?? false);
}
