// wTCX.dart
// Tools to generate a TCX file
// To test on Strava

import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'models/TCXModel.dart';
import 'logTool.dart';

// Generate the TCX file
/// from a TCX Model
/// Store the TCX file in genera
/// TODO: Add return code
///
// Future<String> writeTCX(TCXModel tcxInfos, String filename) async {
Future<void> writeTCX(TCXModel tcxInfos, String filename) async {
  Future<File> _localFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    var path = directory.path;
    return File('$path/$fileName');
  }

  // Now generate a new file from rideData
  var generatedTCXFile = await _localFile(filename);
  var sink = generatedTCXFile.openWrite(mode: FileMode.writeOnly);

  String contents = '';

  // Generate the prolog of the TCX file
  final String prolog = """ <?xml version="1.0" encoding="UTF-8"?>
    <TrainingCenterDatabase
    xsi:schemaLocation="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2 http://www.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd"
    xmlns:ns5="http://www.garmin.com/xmlschemas/ActivityGoals/v1"
    xmlns:ns3="http://www.garmin.com/xmlschemas/ActivityExtension/v2"
    xmlns:ns2="http://www.garmin.com/xmlschemas/UserProfile/v2"
    xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns4="http://www.garmin.com/xmlschemas/ProfileExtension/v1">\n""";

  final String tailActivity = """      <Creator xsi:type="Device_t">
        <Name>rw_TCX</Name>
        <UnitId>3873921795</UnitId>
        <ProductID>1736</ProductID>
        <Version>
          <VersionMajor>4</VersionMajor>
          <VersionMinor>20</VersionMinor>
          <BuildMajor>0</BuildMajor>
          <BuildMinor>0</BuildMinor>
        </Version>
      </Creator>
  </Activity> """;

  final String tail = """    <Author xsi:type="Application_t">
    <Name>Connect Api</Name>
    <Build>
      <Version>
        <VersionMajor>0</VersionMajor>
        <VersionMinor>0</VersionMinor>
        <BuildMajor>0</BuildMajor>
        <BuildMinor>0</BuildMinor>
      </Version>
    </Build>
    <LangID>en</LangID>
    <PartNumber>006-D2449-00</PartNumber>
  </Author>
  </TrainingCenterDatabase>""";

  String activityBiking = """<Activity Sport="Biking">\n""";

  String activitiesContent = '';

  // Add Activity
  //-------------
  String activityContent = activityBiking;

  // Add ID
  activityContent = activityContent +
      addElement('Id', createTimestamp(tcxInfos.dateActivity));

  displayInfo(' $activityContent');

  // Add lap
  //---------
  String lapContent = '';
  lapContent = lapContent + addElement('TotalTimeSeconds', '1688.0');
  // Add Total distace in meters
  lapContent = lapContent + addElement('DistanceMeters', '88888.0');
  // Add Maximum speed in meter/second
  lapContent = lapContent + addElement('MaximumSpeed', '12.8888');
  // Add calories
  lapContent = lapContent + addElement('Calories', '12.8888');
  // Add intensity (what is the meaning?)
  lapContent = lapContent + addElement('Intensity', 'Active');
  // Add intensity (what is the meaning?)
  lapContent = lapContent + addElement('TriggerMethod', 'Manual');

  // Add track inside the lap
  String trackContent = '';
  int counterTrackpoint = 0;

  for (var point in tcxInfos.points) {
    String trackPoint = addTrackPoint(point);
    counterTrackpoint++;

    // To display the first 3 trackPoints
    if (counterTrackpoint < 4) {
      displayInfo(' $trackPoint');
    } // temp disp for the for loop

    trackContent = trackContent + trackPoint;
  }
  lapContent = lapContent + addElement('Track', trackContent);

  activityContent = activityContent +
      addAttribute('Lap', 'StartTime', createTimestamp(tcxInfos.dateActivity),
          lapContent);

  activityContent = activityContent + tailActivity;

  activitiesContent = addElement('Activities', activityContent);

  // Create the complete tcx file
  contents = prolog + activitiesContent + tail;

  sink.write(contents);
  // Close the file
  await sink.flush();
  await sink.close();

// return contents;
}

/// Generate a string that will include
/// all the tags corresponding to TCX trackpoint
///
/// Extension handling is missing for the moment
///
String addTrackPoint(TrackPoint point) {
  String _returnString;

  _returnString = "<Trackpoint>\n";
  _returnString = _returnString + addElement('Time', point.timeStamp);
  _returnString = _returnString +
      addPosition(point.latitude.toString(), point.longitude.toString());
  _returnString =
      _returnString + addElement('AltitudeMeters', point.altitude.toString());
  _returnString =
      _returnString + addElement('DistanceMeters', point.distance.toString());

  if (point.speed != null) {
    _returnString = _returnString + addExtension('Speed', point.speed);
  }

  if (point.power != null) {
    _returnString = _returnString + addExtension('Watts', point.power);
  }

  if (point.heartRate != null) {
    _returnString = _returnString + addHeartRate(point.heartRate);
  }

  _returnString = _returnString + "</Trackpoint>\n";

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

  extensionMid =
      '     <ns3:' + tag + '>' + _value.toString() + '</ns3:' + tag + '>\n';

  returnString = extensionBeg + extensionMid + extensionEnd;

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

/// create a position something like
/// <Position>
///   <LatitudeDegrees>43.14029800705612</LatitudeDegrees>
///   <LongitudeDegrees>5.771340150386095</LongitudeDegrees>
/// </Position>
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

  returnString = '<' + tag + ' ' + attribute + '="' + value + '">\n';
  returnString = returnString + content + '</' + tag + '>\n';

  return returnString;
}

/// Create timestamp for <Time> element in TCX file
///
/// To get 2019-03-03T11:43:46.000Z
/// utc time
/// Need to add T in the middle
String createTimestamp(DateTime dateTime) {
  String _returnString;

  _returnString = dateTime.toUtc().toString();
  _returnString = _returnString.replaceFirst(' ', 'T');

  return _returnString;
}
