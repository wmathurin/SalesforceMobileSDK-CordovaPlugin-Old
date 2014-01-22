//--------------------------------------
// Reading arguments from command line
//--------------------------------------
if (process.argv.length < 4) {
    console.log('Error missing arguments\n' + 
                'Usage: node postinstall.js  <targetAndroidApi> <useSmartStore>\n' + 
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

// Function to removes classpathentry for cordova.jar
var fixClassPath = function(data) {
    return data.replace(/\t<classpathentry.*cordova.*\n/, '').split(/\n/)
};

// Function to fix AndroidManifest.xml
var fixAndroidManifest = function(data) {
    // Remove first <application />
    data = data.substring(0, data.indexOf("<application")) + data.substring(data.indexOf("</application>") + "</application>".length);

    // Change app class when using smartstore
    if (useSmartStore) {
        data = data.replace(/com\.salesforce\.androidsdk\.app\.HybridApp/, 'com.salesforce.androidsdk.smartstore.app.HybridAppWithSmartStore');
    }
    
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
var libProject = useSmartStore ? '../../plugins/com.salesforce/android/hybrid/SmartStore' : '../../plugins/com.salesforce/android/native/SalesforceSDK';
var cordovaLibProject = '../../../../../platforms/android/CordovaLib';

console.log('Fixing application AndroidManifest.xml');
fixFile('platforms/android/AndroidManifest.xml', fixAndroidManifest);

console.log('Fixing application project.properties');
fixFile('platforms/android/project.properties', fixProjectProperties);

console.log('Removing cordova.jar reference from SalesforceSDK\'s .classpath');
fixFile('plugins/com.salesforce/android/native/SalesforceSDK/.classpath', fixClassPath);

console.log('Updating application to use ' + (useSmartStore ? 'SmartStore' : ' SalesforceSDK') + ' library project ');
exec('cd platforms/android/; android update project -p . -t "android-' + targetAndroidApi + '" -l ' + libProject);

console.log('Updating SalesforceSDK to use cordovaLib');
exec('cd plugins/com.salesforce/android/native/SalesforceSDK; android update project -p . -t "android-' + targetAndroidApi + '" -l ' + cordovaLibProject);

if (useSmartStore) {
    console.log('Updating SmartStore library target android api');
    exec('cd plugins/com.salesforce/android/hybrid/SmartStore; android update project -p . -t "android-' + targetAndroidApi + '"');
}
