// logTool.dart
// Very simple tool
// To display debug message or not

import 'package:flutter/foundation.dart';

bool isRW_TCXInDebug = true; // set to true to see debug message in rTCX or wTCX

/// To display debug info in Strava API
void displayInfo(String message) {
  if (isRW_TCXInDebug) {
    var msgToDisplay = '--> RW_TCX: ' + message;
    debugPrint(msgToDisplay);
  }
}
