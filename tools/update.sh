#!/bin/bash

if [[ "clean" == "$1" ]]
then
    echo "*** Cleanup ***"
    echo "Removing bower_components"
    rm -rf bower_components
    echo "Removing tmp"
    rm -rf tmp
fi

if [ ! -d "tools" ]
then
    echo "You must run this tool from the root directory of your repo clone"
else
    echo "Fetching latest ios, android and shared repos"
    bower install
    echo "*** Android ***"
    echo "Copying SalesforceSDK library out of bower_components"
    mkdir -p android/native
    cp -r bower_components/mobilesdk-android/native/SalesforceSDK android/native/
    echo "Copying SmartStore library out of bower_components"
    mkdir -p android/hybrid
    cp -r bower_components/mobilesdk-android/hybrid/SmartStore android/hybrid/
    echo "Copying icu461.zip out of bower_components"
    mkdir -p android/assets
    cp bower_components/mobilesdk-android/external/sqlcipher/assets/icudt46l.zip android/assets/
    echo "Copying sqlcipher libs out of bower_components"
    cp -r bower_components/mobilesdk-android/external/sqlcipher/libs/* android/hybrid/SmartStore/libs/    
    echo "*** iOS ***"
    mkdir -p tmp
    echo "Copying SalesforceHybridSDK library out of bower_components"    
    unzip bower_components/mobilesdk-ios-distribution/SalesforceHybridSDK-Debug.zip -d tmp
    echo "Copying SalesforceOAuth library out of bower_components"    
    unzip bower_components/mobilesdk-ios-distribution/SalesforceOAuth-Debug.zip -d tmp
    echo "Copying SalesforceCore library out of bower_components"    
    unzip bower_components/mobilesdk-ios-distribution/SalesforceSDKCore-Debug.zip -d tmp
    echo "Copying SalesforceCommonUtils library out of bower_components"    
    cp -r bower_components/mobilesdk-ios-dependencies/SalesforceCommonUtils  tmp
    echo "Copying openssl library out of bower_components"    
    cp -r bower_components/mobilesdk-ios-dependencies/openssl  tmp
    echo "Copying sqlcipher library out of bower_components"    
    cp -r bower_components/mobilesdk-ios-dependencies/sqlcipher  tmp
    echo "Copying needed headers to ios/headers"
    mkdir -p ios/headers
    copy_and_fix_header ()
    {
        echo "* Fixing and copying $1"
        find tmp -name $1 | xargs sed 's/\#import\ \<Salesforce.*\/\(.*\)\>/#import "\1"/' > ios/headers/$1
    }
    copy_and_fix_header SFHybridViewConfig.h
    copy_and_fix_header SFHybridViewController.h
    copy_and_fix_header SFOAuthCoordinator.h
    copy_and_fix_header SFOAuthCredentials.h
    copy_and_fix_header SFOAuthInfo.h
    copy_and_fix_header SFAuthenticationManager.h
    copy_and_fix_header SFIdentityCoordinator.h
    copy_and_fix_header SFPushNotificationManager.h
    copy_and_fix_header SFLogger.h
    echo "Copying needed libraries to ios/frameworks"
    mkdir -p ios/frameworks
    copy_lib ()
    {
        echo "* Copying $1"
        find tmp -name $1 -exec cp {} ios/frameworks/ \;
    }
    copy_lib libSalesforceCommonUtils.a
    copy_lib libSalesforceHybridSDK.a
    copy_lib libSalesforceOAuth.a
    copy_lib libSalesforceSDKCore.a
    copy_lib libcrypto.a
    copy_lib libssl.a
    copy_lib libsqlcipher.a
    echo "Copying AppDelegate.h/.m out of bower_components"
    mkdir -p ios/Classes
    cp -r bower_components/mobilesdk-ios-package/Templates/HybridAppTemplate/__HybridTemplateAppName__/__HybridTemplateAppName__/Classes/AppDelegate.* ios/Classes/
    echo "Copying Settings.bundle out of bower_components"
    mkdir -p ios/resources
    cp -r bower_components/mobilesdk-ios-package/Templates/HybridAppTemplate/__HybridTemplateAppName__/__HybridTemplateAppName__/Settings.bundle ios/resources/
    echo "*** Shared ***"
    echo "Copying cordova.force.js out of bower_components"
    mkdir -p shared/libs
    cp -r bower_components/mobilesdk-shared/libs/cordova.force.js shared/libs/
    node tools/split.js
fi
