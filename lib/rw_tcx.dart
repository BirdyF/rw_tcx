library rw_tcx;

import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'models/TCXModel.dart';
import 'rTCX.dart';
import 'wTCX.dart';

Future<File>  _localFile(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  var path = directory.path;
  return File('$path/fileName');
}

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
  print('result ${result.content}');


  Tag activity = searchAttribute('Activity', contents);
  print('Activity ${activity.content}');

  Tag totalDistance = searchElement('DistanceMeters', contents);
  print('Distance ${totalDistance.content}');

  Tag calories = searchElement('Calories', contents);
  print('Calories ${calories.content}');

  String speed = searchExtension('Speed', contents, index: 0);
  print('Speed $speed');

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
    print(
        'idx : ${trackPoint.index}  -- ${trackPoint.timeStamp} -- ${trackPoint.distance}');
    if (trackPoint.index == null) {
      // No more trackpoint available in the String
      print('No more trackPoints!');
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
        print('skip this position ${trackPoint.timeStamp}');
      }
    }
  } while (!noMoreTrackPoints);
  return rideData;
}

// Generate the TCX file
/// from a TCX Model
///
Future<void> writeTCX(TCXModel tcxInfos, String filename) async {
  // Now generate a new file from rideData
  var generatedTCXFile = await _localFile(filename);
  var sink = generatedTCXFile.openWrite(mode: FileMode.writeOnly);

  String contents = '';

  // Generate the prolog of the TCX file
  String prolog = """ <?xml version="1.0" encoding="UTF-8"?>
    <TrainingCenterDatabase
    xsi:schemaLocation="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2 http://www.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd"
    xmlns:ns5="http://www.garmin.com/xmlschemas/ActivityGoals/v1"
    xmlns:ns3="http://www.garmin.com/xmlschemas/ActivityExtension/v2"
    xmlns:ns2="http://www.garmin.com/xmlschemas/UserProfile/v2"
    xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns4="http://www.garmin.com/xmlschemas/ProfileExtension/v1">""";



  String tail = """
  <Creator>
  <Name>rw_tcx</Name>
  </Creator>
  </Activity>
  </Activities>
  </TrainingCenterDatabase>
  """;

  sink.write('$prolog\n');

  contents = prolog;

  String activitiesContent = '';

  // Add Activity
  //-------------
  String activityContent = '';

  // TODO to replace with real data
  var date = DateTime(2019, 6, 11, 16, 50);

  // Add ID
  activityContent =
      activityContent + '\n' + addElement('Id', createTimestamp(date));

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

    // TODO: Remove the temp shortcut
    // Only the first 3 trackpoints
    //==============================
    if (counterTrackpoint == 4) {
      break;
    } // temp exit for the for loop?

    trackContent = trackContent + trackPoint;
  }
  lapContent = lapContent + addElement('Track', trackContent);

  activityContent = activityContent +
      addAttribute('Lap', 'StartTime', createTimestamp(date), lapContent);

  activitiesContent = addElement('Activities', activityContent);

  contents = prolog + activitiesContent + tail;


  // sink = generatedTCXFile.openWrite(mode: FileMode.append);
  sink.write(contents);
  // Close the file
  await sink.flush();
  await sink.close();

// Add the tail of the TCX file

// Check what is the result of the file generation
  sink = generatedTCXFile.openWrite(mode: FileMode.append);

  contents = await generatedTCXFile.readAsString();
  print('The file is ${contents.length} bytes long.');
  print(' $contents');

  // Close the file
  await sink.flush();
  await sink.close();
}
