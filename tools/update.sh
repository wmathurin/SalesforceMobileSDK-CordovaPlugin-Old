#!/bin/bash


if [ ! -d "tools" ]
then
    echo "You must run this tool from the root directory of your repo clone"
else
    echo "Fetching latest ios, android and shared repos"
    bower install
    echo "*** Android ***"
    echo "Copying SalesforceSDK library out of bower_coponents"
    mkdir -p android/native
    cp -r bower_components/mobilesdk-android/native/SalesforceSDK android/native/
    echo "Copying SmartStore library out of bower_coponents"
    mkdir -p android/hybrid
    cp -r bower_components/mobilesdk-android/hybrid/SmartStore android/hybrid/
    echo "Copying icu461.zip out of bower_coponents"
    mkdir -p android/assets
    cp bower_components/mobilesdk-android/external/sqlcipher/assets/icudt46l.zip android/assets/
    echo "Copying sqlcipher libs out of bower_components"
    cp -r bower_components/mobilesdk-android/external/sqlcipher/libs/* android/hybrid/SmartStore/libs/    
    echo "*** iOS ***"
    mkdir -p ios/Dependencies
    echo "Copying SalesforceHybridSDK library out of bower_components"    
    unzip bower_components/mobilesdk-ios-distribution/SalesforceHybridSDK-Debug.zip -d ios/Dependencies
    echo "Copying SalesforceOAuth library out of bower_components"    
    unzip bower_components/mobilesdk-ios-distribution/SalesforceOAuth-Debug.zip -d ios/Dependencies
    echo "Copying SalesforceCore library out of bower_components"    
    unzip bower_components/mobilesdk-ios-distribution/SalesforceSDKCore-Debug.zip -d ios/Dependencies
    echo "Copying SalesforceCommonUtils library out of bower_components"    
    cp -r bower_components/mobilesdk-ios-dependencies/SalesforceCommonUtils  ios/Dependencies
    echo "Copying openssl library out of bower_components"    
    cp -r bower_components/mobilesdk-ios-dependencies/openssl  ios/Dependencies
    echo "Copying sqlcipher library out of bower_components"    
    cp -r bower_components/mobilesdk-ios-dependencies/sqlcipher  ios/Dependencies
    echo "Copying template out of bower_components"
    mkdir -p ios/Template
    cp -r bower_components/mobilesdk-ios-package/Templates/HybridAppTemplate/__HybridTemplateAppName__/__HybridTemplateAppName__/ ios/Template
    echo "*** Shared ***"
    echo "Copying cordova.force.js out of bower_coponents"
    mkdir -p shared/libs
    cp -r bower_components/mobilesdk-shared/libs/cordova.force.js shared/libs/
    node tools/split.js
fi
