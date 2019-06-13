// TCXModel.Duration


/// for the moment lap is not handled
/// handle speed extension
class TCXModel {

  String activityType;
  double totalDistance; // Total distance in meters
  double totalTime; // in seconds
  double maxSpeed; // in m/s
  int calories;
  String intensity;
  List<TrackPoint> points;

  // Related to device that generated the data
  String creator;
  String deviceName;
  String unitID;
  String productID;
  String versionMajor;
  String versionMinor;
  String buildMajor;
  String buildMinor;

  // Related to software used to generate the TCX file
  String author;
  String name;
  String swVersionMajor;
  String swVersionMinor;
  String buildVersionMajor;
  String buildVersionMinor;
  String langID;
  String partNumber;


  // to get points
  List<TrackPoint> get getPoints {
    List<TrackPoint> returnpoints = List<TrackPoint>();
    for (var point in points) {
        returnpoints.add(point);
    }

    return returnpoints;
  }

}


class TrackPoint {
  double latitude;  // in degrees
  double longitude;
  String timeStamp;  
  double altitude; // in meters
  double speed;  // Inst speed in m/s
  double distance; // in meters

  double cadence;   // Not handled yet
  double power;     // not handled yet
  double hearRate;  // Not handled yet

  int index;    // position of the trackpoint in the string
                // used when reading the TCX file
}

class Tag {

  Tag({this.content, this.index});

  String content;
  int index;  // Position of the last character of content in the string 
              // used to read a TCX file
}