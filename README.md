# rw_tcx


name: rw_tcx

description: A simple package to read and write TCX file using Dart
With this package it is possible to extract track points for a TCX file or write a valid TCX file from an array of track points 


## Getting Started


It is a Dart only package, Flutter is not needed

 


## How to install
Check on pub.dev/packages to see how to install this package
https://pub.dev/packages/rw_tcx#-installing-tab-


## How to use it

There are only 2 APIs
- readTCX
- writeTCX

## Example

There is a complete example showing how to use readTCX and writeTCX
For readTCX, the sample2.tcx stored in assets is coming from Garmin Connect export
For writeTCX, the generated TCX file is sent to Google Drive in addition to be uploaded to Strava


## To check your TCX file

There is a nice online tool https://www.gpsies.com/convert.do to get a detailed explanation of what is wrong in your TCX file 



## Tested on:

So far only on Android 8.0 for the moment

## Contributors welcome!

If you spot a problem/bug or if you consider that the code could be better please post a new issue.
I have developed this package to be able to upload a TCX to Strava so rTCX.dart is very basic. 
Feel free to contribute to add more features.





## License:
rw_tcx is provided under a MIT License. Copyright (c) 2019 Patrick FINKELSTEIN


