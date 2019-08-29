import 'package:flutter/material.dart';

import 'package:flutter/services.dart' show rootBundle;

import 'secret.dart'; // Where Strava app secret and clientId stored

import 'package:rw_tcx/models/TCXModel.dart';
import 'package:rw_tcx/rTCX.dart';
import 'package:rw_tcx/wTCX.dart';

import 'package:path_provider/path_provider.dart';  // Needed for getApplications

import 'package:strava_flutter/strava.dart';
import 'package:strava_flutter/Models/fault.dart';



// Used by Google sign in 
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'dart:io' as io;


import 'package:http/http.dart'
    show BaseRequest, Response, StreamedResponse;
import 'package:http/io_client.dart';
class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;

  GoogleHttpClient(this._headers) : super();

  @override
  Future<StreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Object url, {Map<String, String> headers}) =>
      super.head(url, headers: headers..addAll(_headers));

}



main(List<String> args) async {
  print('Start of rw_tcx example');


  // First init of Strava API stuff
  // Do authentication with the right scope
  final strava = Strava(
      true, // To get display info in API
      secret);

  bool isAuthOk = false;

  isAuthOk = await strava.oauth(clientId, 'activity:write', secret, 'auto');

  print('---> Strava Authentication result: $isAuthOk');


  // Start Google Auth to try access Google Drive

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive'],
  );

  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;


   final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  // final FirebaseUser user = await _auth.signInWithCredential(credential);
  AuthResult authResult = await _auth.signInWithCredential(credential);

  assert(!authResult.user.isAnonymous);

 
  assert(await authResult.user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(authResult.user.uid == currentUser.uid);

  print('signInWithGoogle succeeded: ${authResult.user}');

  var client = GoogleHttpClient(await googleSignInAccount.authHeaders);

  var driveApi = drive.DriveApi(client);



  // Get the list of file from to root directory 
  // of the google drive
  // useful to check that driveApi is working 

  var fileList = await driveApi.files.list();
  // Display for 10 file names
  fileList.files.forEach((file) => print('---${file.name})'));


  print('Read a TCX file');

  // Use the asset file to test without having to create internally a ride
  TCXModel rideData = TCXModel();

  String contents = '';

  try {
    // Read the test file sample1.tcx in assets

    contents = await rootBundle.loadString('assets/sample2.tcx');

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

  tcxInfos.dateActivity = DateTime(2019, 8, 15, 18, 28);


  await writeTCX(tcxInfos, 'generatedSample.tcx');

  print('End of write TCX test');



  final directory = await getApplicationDocumentsDirectory();
 
  String path = directory.path;

  var destFile = drive.File.fromJson({
    'mimeType': 'text/plain',
    'name': 'test_rw_tcx.txt', 
  });
  

  io.File fileToUpload  = io.File('$path/generatedSample.tcx');
  drive.Media mediaContent = drive.Media(fileToUpload.openRead(), fileToUpload.lengthSync());


  var resultFile = await driveApi.files.create(destFile,
  uploadMedia: mediaContent);



  // Now use Strava API to upload the generatedTCX
  // Strava authentication has been done previously
  String dirUpload = (await getApplicationDocumentsDirectory()).path;

  Fault fault = await strava.uploadActivity(
      'Test rw_TCX', 'It is working!', '$dirUpload/generatedSample.tcx', 'tcx');

  print('This is the end!!');



}