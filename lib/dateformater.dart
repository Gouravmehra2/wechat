import 'package:flutter/material.dart';

class MyDateUtils{
  static String getformatedTime({required BuildContext context, required String time}){
    final date = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }
  static String getlastMessageTime(BuildContext context , String time){
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    if(now.day == sent.day && now.month ==sent.month && now.year == sent.year){
      return TimeOfDay.fromDateTime(sent).format(context);
    }
    return '${sent.day} ${sent.month}';
  }
  String getmonth(DateTime date){
    switch(date.month){
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return 'NA';
  }

  static String getLastActiveTime({required BuildContext context , required String lastactive}){
    final int i = int.parse(lastactive);

    if(i== -1) return 'last Seen not available';

    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String FormattedTime = TimeOfDay.fromDateTime(time).format(context);
    if(time.day == now.day && time.month == now.month && time.year == now.year ){
      return 'Last seen today at $FormattedTime';
    }
    if((now.difference(time).inHours/ 24).round() == 1){
      return 'Last seen at yesterday at $FormattedTime ';
    }
    String month = _getMonth(time);
    return 'last seen on ${time.day} $month  on $FormattedTime';

  }
  static String _getMonth(DateTime date){
    switch(date.month){
    case 1:
    return 'Jan';
    case 2:
    return 'Feb';
    case 3:
    return 'Mar';
    case 4:
    return 'Apr';
    case 5:
    return 'May';
    case 6:
    return 'June';
    case 7:
    return 'July';
    case 8:
    return 'Aug';
    case 9:
    return 'Sep';
    case 10:
    return 'Oct';
    case 11:
    return 'Nov';
    case 12:
    return 'Dec';
    }
    return 'NA  ';
  }

}