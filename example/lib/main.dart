import 'package:flutter/material.dart';

import 'package:flutter/services.dart' show rootBundle;

import 'secret.dart'; // Where Strava app secret is stored
import 'package:rw_tcx/rw_tcx.dart';
import 'package:rw_tcx/models/TCXModel.dart';

// Used by example

main(List<String> args) async {
  print('Start of rw_tcx example');

  print('Read a TCX file');

  // Use the asset file to test without having to create internally a ride
  TCXModel rideData = TCXModel();

  String contents = '';

  try {
    // Read the test file sample1.tcx in assets

    contents = await rootBundle.loadString('assets/sample1.tcx');

    print('contents $contents');

    rideData = readTCX(contents);
  } catch (e) {
    print('error loading assets file:  $e');
  }

  print('Write a TCX file');

  TCXModel tcxInfos = TCXModel();
    
  tcxInfos.points = rideData.points;
  tcxInfos.swVersionMajor = 'SWMajor';
  tcxInfos.swVersionMinor = 'SWMinor';
  tcxInfos.partNumber = 'Part Number';

  await writeTCX(tcxInfos, 'generatedSample.tcx');

  print('End of write TCX test');
  

}
