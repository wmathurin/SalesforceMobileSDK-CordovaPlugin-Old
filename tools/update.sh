#!/bin/bash


if [ ! -d "tools" ]
then
    echo "You must run this tool from the root directory of your repo clone"
else
    echo "Fetching latest android and shared repos"
    bower install
    echo "Copying SalesforceSDK library out of bower_coponents"
    mkdir -p android/native
    cp -r bower_components/mobilesdk-android/native/SalesforceSDK android/native/
    echo "Copying SmartStore library out of bower_coponents"
    mkdir -p android/hybrid
    cp -r bower_components/mobilesdk-android/hybrid/SmartStore android/hybrid/
    echo "Copying icu461.zip out of bower_coponents"
    mkdir -p android/assets
    cp bower_components/mobilesdk-android/external/sqlcipher/assets/icudt46l.zip android/assets/
    echo "Copying cordova.force.js out of bower_coponents"
    mkdir -p shared/libs
    cp -r bower_components/mobilesdk-shared/libs/cordova.force.js shared/libs/
    node tools/split.js
fi
