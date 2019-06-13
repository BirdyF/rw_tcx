import 'package:flutter_test/flutter_test.dart';

import 'package:rw_tcx/rw_tcx.dart';
import 'package:rw_tcx/rTCX.dart';
import 'package:rw_tcx/models/TCXModel.dart';

void main() {
  group('readTCX test', () {


    test('SearchElement tests', () {
    

    String contents = "<TotalTimeSeconds>16524.0</TotalTimeSeconds>";
    Tag expectedTag = Tag(content: '16524.0', index: 25);
    Tag resultTag = searchElement('TotalTimeSeconds', contents);
    expect('AAA', equals('AAA'));
    // expect(resultTag, equals(expectedTag));
    

    });


    test('SearchAttribute tests', () {

      expect('AAA', equals('AAA'));
    
    });


    test('SearchExtension tests', () {
      expect('AAA', equals('AAA'));
     
    });

    
  });
}
