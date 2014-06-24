//--------------------------------------
// Reading arguments from command line
//--------------------------------------
if (process.argv.length < 4) {
    console.log('Error missing arguments\n' + 
                'Usage: node postinstall-android.js  <targetAndroidApi> <useSmartStore>\n' + 
                '*  targetAndroidApi: android api (e.g. 19 for KitKat etc)\n' + 
                '*  useSmartStore: true | false\n');
    process.exit(1);
}
var targetAndroidApi = process.argv[2];
var useSmartStore = process.argv[3] == 'true';

//--------------------------------------
// Useful functions
//--------------------------------------
var fs = require('fs');
var exec = require('child_process').exec;
var path = require('path');

var copyFile = function(srcPath, targetPath) {
    fs.createReadStream(srcPath).pipe(fs.createWriteStream(targetPath));
};

var fixFile = function(path, fix) {
    fs.readFile(path, 'utf8', function (err, data) { 
        fs.writeFile(path, fix(data), function (err) {         
            if (err) { 
                console.log(err); 
            } 
        });
    });
};

// Function to removes current cordova library project reference 
var fixSDKProjectProperties = function(data) {
    return data.replace(/android\.library\.reference.*cordova\/framework\n/, '');
};

// Function to fix AndroidManifest.xml
var fixAndroidManifest = function(data) {
    // Change app name and manage space activity
    var androidLabel = "android:label=\"@string/app_name\"";
    var androidManageSpaceActivity = "android:manageSpaceActivity=\"com.salesforce.androidsdk.ui.ManageSpaceActivity\"";
    var appName = "com.salesforce.androidsdk." + (useSmartStore  ? "smartstore.app.HybridAppWithSmartStore"  : "app.HybridApp");
    var androidNameToMatch = "android:name=\"[^\"]*\"";
    var androidName = "android:name=\"" + appName + "\"";
    data = data.replace(new RegExp(androidLabel + " " + androidNameToMatch), androidLabel + " " + androidName + " " + androidManageSpaceActivity);

    // Change target api
    data = data.replace(/android\:targetSdkVersion\=\"19\"/, 'android:targetSdkVersion="' + targetAndroidApi + '"');

    return data;
};

// Function to manifest merger
var fixProjectProperties = function(data) {
    return data + "manifestmerger.enabled=true\n";
};

//--------------------------------------
// Doing actual post installation work
//--------------------------------------
var libProject = useSmartStore ? '../../plugins/com.salesforce/src/android/hybrid/SmartStore' : '../../plugins/com.salesforce/src/android/native/SalesforceSDK';
var cordovaLibProject = '../../../../../../platforms/android/CordovaLib';

console.log('Fixing application AndroidManifest.xml');
fixFile('platforms/android/AndroidManifest.xml', fixAndroidManifest);

console.log('Fixing application project.properties');
fixFile('platforms/android/project.properties', fixProjectProperties);

console.log('Removing cordova library project reference from SalesforceSDK\'s project.properties');
fixFile('plugins/com.salesforce/src/android/native/SalesforceSDK/project.properties', fixSDKProjectProperties);

console.log('Building cordova library');
exec('ant debug', {cwd: path.resolve(process.cwd(), 'platforms/android/CordovaLib')});

console.log('Updating application to use ' + (useSmartStore ? 'SmartStore' : ' SalesforceSDK') + ' library project ');
exec('android update project -p . -t "android-' + targetAndroidApi + '" -l ' + libProject, {cwd: path.resolve(process.cwd(), 'platforms/android')});

console.log('Updating SalesforceSDK to use cordovaLib');
exec('android update project -p . -t "android-' + targetAndroidApi + '" -l ' + cordovaLibProject, {cwd: path.resolve(process.cwd(), 'plugins/com.salesforce/src/android/native/SalesforceSDK')});

console.log('Building SalesforceSDK library');
exec('ant debug', {cwd: path.resolve(process.cwd(), 'plugins/com.salesforce/src/android/native/SalesforceSDK')});


if (useSmartStore) {
    console.log('Updating SmartStore library target android api');
    exec('android update project -p . -t "android-' + targetAndroidApi + '"', {cwd: path.resolve(process.cwd(), 'plugins/com.salesforce/src/android/hybrid/SmartStore')});
    console.log('Building SmartStore library');
    exec('ant debug', {cwd: path.resolve(process.cwd(), 'plugins/com.salesforce/src/android/hybrid/SmartStore')});
}
