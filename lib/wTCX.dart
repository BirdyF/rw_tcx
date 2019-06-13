// wTCX.dart
// Tools to generate a TCX file
// To test on Strava

import 'models/TCXModel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Generate a string that will include
/// all the tags corresponding to TCX trackpoint
///
/// Extension handling is missing for the moment
///
String addTrackPoint(TrackPoint point) {
  String _returnString;
  _returnString = addElement('Time', point.timeStamp);
  _returnString = _returnString +
      addPosition(point.latitude.toString(), point.longitude.toString());
  _returnString =
      _returnString + addElement('AltitudeMeters', point.altitude.toString());
  _returnString =
      _returnString + addElement('DistanceMeters', point.distance.toString());

  // Extensions speed is missing
  if (point.speed != null) {}

  if (point.power != null) {}

  return _returnString;
}

String addPosition(String latitude, String longitude) {
  String returnString;
  returnString = '<Position>\n';

  returnString =
      returnString + '   <LatitudeDegrees>' + latitude + '</LatitudeDegrees>\n';
  returnString = returnString +
      '   <LongitudeDegrees>' +
      longitude +
      '</LongitudeDegrees>\n';

  returnString = returnString + '</Position>\n';

  return returnString;
}

/// create XML element
/// from content string
String addElement(String tag, String content) {
  String returnString;

  returnString = '<' + tag + '>' + content + '</' + tag + '>\n';

  return returnString;
}

/// create XML attribute
/// from content string

String addAttribute(
    String tag, String attribute, String value, String content) {
  String returnString;

  returnString = '<' + tag + attribute + '="' + value + '">\n';
  returnString = returnString + content + '</' + tag + '>\n';

  return returnString;
}

/// Create timestamp for <Time> element in TCX file
///
/// To get 2019-03-03T11:43:46.000Z
/// utc time
String createTimestamp(DateTime dateTime) {
  String _returnString;

  _returnString = dateTime.toUtc().toString();

  return _returnString;
}

Future<File> get _localFile async {
  final directory = await getApplicationDocumentsDirectory();
  var path = directory.path;
  return File('$path/generatedTCX.TCX');
}
