import 'package:flutter_test/flutter_test.dart';

import 'package:rw_tcx/rw_tcx.dart';
import 'package:rw_tcx/rTCX.dart';
import 'package:rw_tcx/wTCX.dart';
import 'package:rw_tcx/models/TCXModel.dart';

void main() {
  group('readTCX test', () {


    test('SearchElement tests', () {
    

    String contents = "<TotalTimeSeconds>16524.0</TotalTimeSeconds>";
    Tag expectedTag = Tag(content: '16524.0', index: 25);
    Tag resultTag = searchElement('TotalTimeSeconds', contents);
    expect('AAA', equals('AAA'));
    expect(resultTag.content, equals(expectedTag.content));
    

    });


    test('SearchAttribute tests', () {

      Tag expectedTag = Tag(content: ' Sport="Biking"', index: 34);
      Tag resultTag = searchAttribute('Activity', ' hjhkjhkj <Activity Sport="Biking"> hjhkjhjk');
      expect(expectedTag.content, equals(resultTag.content));
      expect(expectedTag.index, equals(resultTag.index));
    
    });


    test('SearchExtension tests', () {
      String textExtension = '''<AltitudeMeters>79.80000305175781</AltitudeMeters>
            <DistanceMeters>2.75</DistanceMeters>
            <Extensions>
              <ns3:TPX>
                <ns3:Speed>2.7809998989105225</ns3:Speed>
              </ns3:TPX>
            </Extensions>
          </Trackpoint>''';
      
      String expectedResult = '2.7809998989105225';
      String result = searchExtension('Speed', textExtension);

      expect(expectedResult, equals(result));
    });

    
  });



  group('write TCX test', () {

    test('CreateTimestamp tests', () {
    var date = DateTime(2019, 6, 11, 16, 50);
    String resultTimestamp = createTimestamp(date);
   
    expect(resultTimestamp, equals('2019-06-11 14:50:00.000Z'));

    });
  });
}
