// rTCX.dart 


import 'models/TCXModel.dart';

/// Tools to read a TCX and store the data in 
/// a proper structure
/// 
/// 
/// 
/// Search for the content of a 'double' tag
  /// 
  /// What is between <tag> and </tag>
  /// 
  /// if index is missing start to search at the beginning of the contents string
  Tag searchElement(String tag, String contents, {int index}) {

    String _startTag = '<' + tag + '>';
    Tag _returnTag = Tag();
    int _index = index ?? 0;

    int _pos = contents.indexOf(_startTag, _index);
    if (_pos == -1) {
      print('start tag not found');
      _returnTag.content = '';
    } else {

      // Search for end 
      String _endTag = '</' + tag + '>';
      int _startPos = _pos + _startTag.length;

      int _endPos = contents.indexOf(_endTag, _startPos);
      if (_endPos == -1) {  // Problem end tag not found
        print('start tag not found');
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
      print('start tag not found');
      _returnTag.content = '';
    } else {

      // Search for end 
      String _endTag = '>';
      int _startPos = _pos + _startTag.length;

      int _endPos = contents.indexOf(_endTag, _startPos);
      if (_endPos == -1) {  // Problem end tag not found
        print('start tag not found');
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
      DateTime dateTime  = DateTime.parse(timeStampTag.content);
    } catch (e) {
      print ('Error in dateformat $e');
      return TrackPoint();
    }

   
    // Get latitude and longitude
    Tag position = searchElement('Position', trackPointTag.content, index: 0);
    Tag latitude = searchElement('LatitudeDegrees', position.content);
    Tag longitude = searchElement('LongitudeDegrees', position.content);
    Tag altitude = searchElement('AltitudeMeters', trackPointTag.content);
    Tag distance = searchElement('DistanceMeters', trackPointTag.content);

    String speed = searchExtension('Speed', contents, index: index);

  
    returnTrackPoint.latitude = double.tryParse(latitude.content); 
    returnTrackPoint.longitude = double.tryParse(longitude.content);
    returnTrackPoint.altitude = double.tryParse(altitude.content);
    returnTrackPoint.distance = double.tryParse(distance.content);
    returnTrackPoint.timeStamp = timeStampTag.content;
    returnTrackPoint.speed = double.tryParse(speed);
    returnTrackPoint.index = trackPointTag.index;

  
    if (timeStampTag.content == '' )  
      {
      return TrackPoint();
    } else return returnTrackPoint;

  }


  



