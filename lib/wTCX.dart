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

  
  if (point.speed != null) {
    addExtension('Speed', point.speed);
  }

  if (point.power != null) {
    addExtension('Watts', point.power);
  }

  if (point.heartRate != null) {
    addHeartRate(point.heartRate);
  }


  return _returnString;
}



/// Add an extension like 
/// 
///  <Extensions>
///              <ns3:TPX>
///                <ns3:Speed>1.996999979019165</ns3:Speed>
///              </ns3:TPX>
///            </Extensions>
///
/// Does not handle mutiple values like
/// Speed AND Watts in the same extension
/// 
String addExtension(String tag, double value) {

  String returnString;
  String extensionBeg = """<Extensions>\n   <ns3:TPX>\n""";
  String extensionMid;

  String extensionEnd = """   </ns3:TPX>\n</Extensions>\n""";

  double _value = value ?? 0.0; 
  
  extensionMid = '     <ns3:' + tag + '>' + _value.toString() + '</ns3:' + tag + '>\n';

  returnString = extensionBeg +  extensionMid +  extensionEnd;

  return returnString;


}


/// Add heartRate in TCX file to look like
///
///       <HeartRateBpm>
///         <Value>61</Value>
///       </HeartRateBpm>
/// 
String addHeartRate(int heartRate) {
  String heartRateContentBeg = """
                 <HeartRateBpm>
              <Value>""";
              
  String heartRateContentEnd = """</Value>
            </HeartRateBpm>\n""";
  int _heartRate = heartRate ?? 0;
  String _valueString = _heartRate.toString();
    return heartRateContentBeg + _valueString + heartRateContentEnd;

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
