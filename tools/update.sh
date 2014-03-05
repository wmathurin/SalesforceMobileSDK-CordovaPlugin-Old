#!/bin/bash

if [ ! -d "tools" ]
then
    echo "You must run this tool from the root directory of your repo clone"
else
    echo "*** Fetching latest ios, android and shared repos ***"
    bower install

    echo "*** Creating directories ***"
    echo "Creating tmp directory"
    mkdir -p tmp
    echo "Creating android directories"
    mkdir -p src/android/native
    mkdir -p src/android/hybrid
    mkdir -p src/android/assets
    echo "Creating ios directories"
    mkdir -p src/ios/headers
    mkdir -p src/ios/frameworks
    mkdir -p src/ios/classes
    mkdir -p src/ios/resources

    echo "*** Android ***"
    echo "Copying SalesforceSDK library out of bower_components"
    cp -r bower_components/mobilesdk-android/native/SalesforceSDK src/android/native/
    echo "Copying SmartStore library out of bower_components"
    cp -r bower_components/mobilesdk-android/hybrid/SmartStore src/android/hybrid/
    echo "Copying icu461.zip out of bower_components"
    cp bower_components/mobilesdk-android/external/sqlcipher/assets/icudt46l.zip src/android/assets/
    echo "Copying sqlcipher libs out of bower_components"
    cp -r bower_components/mobilesdk-android/external/sqlcipher/libs/* src/android/hybrid/SmartStore/libs/    

    echo "*** iOS ***"
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
    echo "Copying and fixing needed headers to src/ios/headers"
    copy_and_fix_header ()
    {
        echo "* Fixing and copying $1"
        find tmp -name $1 | xargs sed 's/\#import\ \<Salesforce.*\/\(.*\)\>/#import "\1"/' > src/ios/headers/$1
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
    echo "Copying needed libraries to src/ios/frameworks"
    copy_lib ()
    {
        echo "* Copying $1"
        find tmp -name $1 -exec cp {} src/ios/frameworks/ \;
    }
    copy_lib libSalesforceCommonUtils.a
    copy_lib libSalesforceHybridSDK.a
    copy_lib libSalesforceOAuth.a
    copy_lib libSalesforceSDKCore.a
    copy_lib libcrypto.a
    copy_lib libssl.a
    copy_lib libsqlcipher.a
    echo "Copying Settings.bundle out of bower_components"
    cp -r bower_components/mobilesdk-ios-package/Templates/NativeAppTemplate/__NativeTemplateAppName__/__NativeTemplateAppName__/Settings.bundle src/ios/resources/
    echo "Copying SalesforceSDKResources.bundle out of bower_components"
    cp -r bower_components/mobilesdk-ios-distribution/SalesforceSDKResources.bundle src/ios/resources/

    echo "*** Shared ***"
    echo "Copying split cordova.force.js out of bower_components"
    node tools/split.js bower_components/mobilesdk-shared/libs/cordova.force.js

    echo "*** Cleanup ***"
    rm -rf bower_components
    rm -rf tmp
fi


