import 'package:flutter/material.dart';
class Dialogs{
  static void showSnackbar(BuildContext context , String msg){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg),
            backgroundColor: Colors.black.withOpacity(.5),
            behavior: SnackBarBehavior.floating,
        )
    );
  }
}

