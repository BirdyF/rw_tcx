// rTCX.dart

import 'models/TCXModel.dart';
import 'logTool.dart';

/// Generate the ride data structure
/// from a string
/// Not tested in detail because main goal
/// is to use writeTCX
///
TCXModel readTCX(String contents) {
  TCXModel rideData = TCXModel();
  rideData.points = List<TrackPoint>();

  // Search for the content of a tag
  Tag result = searchElement('Id', contents);
  displayInfo('result ${result.content}');

  Tag activity = searchAttribute('Activity', contents);
  displayInfo('Activity ${activity.content}');

  Tag totalDistance = searchElement('DistanceMeters', contents);
  displayInfo('Distance ${totalDistance.content}');

  Tag calories = searchElement('Calories', contents);
  displayInfo('Calories ${calories.content}');

  String speed = searchExtension('Speed', contents, index: 0);
  displayInfo('Speed $speed');

  // Start to store data in rideData structure
  rideData.totalDistance = double.tryParse(totalDistance.content);

  // search for sport= in the result and remove it
  List<String> _activity = activity.content.split('=');
  String activityType = _activity[1]; // Remove additional " "
  activityType = activityType.substring(1, activityType.length - 1);

  rideData.activityType = activityType;

  rideData.maxSpeed = double.tryParse(speed);
  rideData.calories = int.tryParse(calories.content);

  // Read now all the trackpoints
  //------------------------------
  bool noMoreTrackPoints = false;
  int idx = 0;

  do {
    TrackPoint trackPoint = extractTrackpoint(contents, idx);

    // Move to the next
    idx = trackPoint.index;
    // displayInfo(
    // 'idx : ${trackPoint.index}  -- ${trackPoint.timeStamp} -- ${trackPoint.distance}');
    if (trackPoint.index == null) {
      // No more trackpoint available in the String
      displayInfo('No more trackPoints!');
      noMoreTrackPoints = true;
    } else {
      // Add a new point in rideData

      // If position is missing skip this trackpoint
      // in garmin connect sometimes position is missing in trackpoint
      if ((trackPoint.latitude != null) &&
          (trackPoint.longitude != null) &&
          (trackPoint != null)) {
        rideData.points.add(trackPoint);
      } else {
        displayInfo('skip this position ${trackPoint.timeStamp}');
      }
    }
  } while (!noMoreTrackPoints);
  return rideData;
}

/// Tools to read a TCX and store the data in
/// a proper structure
///
///
///
/// Search for the content of a 'double' tag
///
/// What is between <tag> and </tag>
///
/// return index 0 and content '' if search is not successful
///
/// if index is missing start to search at the beginning of the contents string
Tag searchElement(String tag, String contents, {int index}) {
  String _startTag = '<' + tag + '>';
  Tag _returnTag = Tag();
  int _index = index ?? 0;

  int _pos = contents.indexOf(_startTag, _index);
  if (_pos == -1) {
    // displayInfo('start Element not found $_startTag');
    _returnTag.content = '';
  } else {
    // Search for end
    String _endTag = '</' + tag + '>';
    int _startPos = _pos + _startTag.length;

    int _endPos = contents.indexOf(_endTag, _startPos);
    if (_endPos == -1) {
      // Problem end tag not found
      displayInfo('End Element not found $_endTag');
      _returnTag.content = '';
    } else {
      // Get what is between the start tag and end tag
      _returnTag.content = contents.substring(_startPos, _endPos);
      _returnTag.index = _endPos;
    }
  }
  return _returnTag;
}

/// Search for the content of a 'single' tag
///
/// What is between '<tag' and  '>'
///
/// if index is missing start to search at the beginning of the contents string
/// return the content and the index of the last character of the content found
Tag searchAttribute(String tag, String contents, {int index}) {
  String _startTag = '<' + tag;
  Tag _returnTag = Tag();
  _returnTag.index = 0;
  int _index = index ?? 0;

  int _pos = contents.indexOf(_startTag, _index);
  if (_pos == -1) {
    displayInfo('start Attribute not found $_startTag');
    _returnTag.content = '';
  } else {
    // Search for end
    String _endTag = '>';
    int _startPos = _pos + _startTag.length;

    int _endPos = contents.indexOf(_endTag, _startPos);
    if (_endPos == -1) {
      // Problem end tag not found
      displayInfo('end Attribute not found $_endTag');
      _returnTag.content = '';
    } else {
      // Get what is between the start tag and end tag
      _returnTag.content = contents.substring(_startPos, _endPos);
      _returnTag.index = _endPos;
    }
  }
  return _returnTag;
}

/// Search extension that is nested in
///
/// like
///       <Extensions>
///            <ns3:TPX>
///              <ns3:Speed>2.7809998989105225</ns3:Speed>
///            </ns3:TPX>
///       </Extensions>
///
String searchExtension(String tag, String contents, {int index}) {
  Tag _returnTag = Tag();
  int _index = index ?? 0;
  // Search for the content of extensions
  Tag _insideExt = searchElement('Extensions', contents, index: _index);
  if (_insideExt.content != '') {
    // search now for what is between <ns3:tag> and </ns3:tag>
    _returnTag = searchElement('ns3:' + tag, _insideExt.content);
  }
  return _returnTag.content;
}

/// Get data from a trackpoint
///
/// latitude, longitude
/// altitude
/// speed
/// Give also the index of the last character of the trackpoint content
///
///        <Trackpoint>
///          <Time>2019-03-03T07:08:22.000Z</Time>
///          <Position>
///            <LatitudeDegrees>43.16713904030621</LatitudeDegrees>
///            <LongitudeDegrees>6.042847512289882</LongitudeDegrees>
///          </Position>
///          <AltitudeMeters>79.80000305175781</AltitudeMeters>
///          <DistanceMeters>2.75</DistanceMeters>
///          <Extensions>
///            <ns3:TPX>
///              <ns3:Speed>2.7809998989105225</ns3:Speed>
///            </ns3:TPX>
///          </Extensions>
///        </Trackpoint>
TrackPoint extractTrackpoint(String contents, int index) {
  TrackPoint returnTrackPoint = TrackPoint();

  // Search for the first trackpoint in the string contents
  Tag trackPointTag = searchElement('Trackpoint', contents, index: index);
  // Get the timestamp
  Tag timeStampTag = searchElement('Time', contents, index: index) ?? '';

  // Convert the timestamp into DateTime
  try {
    DateTime dateTime = DateTime.parse(timeStampTag.content);
    returnTrackPoint.date = dateTime;
  } catch (e) {
    displayInfo('Error in dateformat $e -> ${timeStampTag.content}');
    // This error will happen if it is the end of the trackpoints
    return TrackPoint();
  }

  // Get latitude and longitude
  Tag position = searchElement('Position', trackPointTag.content, index: 0);
  Tag latitude = searchElement('LatitudeDegrees', position.content);
  Tag longitude = searchElement('LongitudeDegrees', position.content);
  Tag altitude = searchElement('AltitudeMeters', trackPointTag.content);
  Tag distance = searchElement('DistanceMeters', trackPointTag.content);
  Tag heartRateWithValue = searchElement('HeartRateBpm', contents);
  // now remove 'value' tag
  Tag heartRate = searchElement('Value', heartRateWithValue.content);

  String speed = searchExtension('Speed', contents, index: index);
  String watts = searchExtension('Watts', contents, index: index);

  returnTrackPoint.latitude = double.tryParse(latitude.content);
  returnTrackPoint.longitude = double.tryParse(longitude.content);
  returnTrackPoint.altitude = double.tryParse(altitude.content);
  returnTrackPoint.distance = double.tryParse(distance.content);
  returnTrackPoint.heartRate = int.tryParse((heartRate.content));
  returnTrackPoint.timeStamp = timeStampTag.content;
  returnTrackPoint.speed = double.tryParse(speed);
  returnTrackPoint.power = double.tryParse(watts);
  returnTrackPoint.index = trackPointTag.index;

  if (timeStampTag.content == '') {
    return TrackPoint();
  } else
    return returnTrackPoint;
}
