//--------------------------------------
// Reading arguments from command line
//--------------------------------------
if (process.argv.length > 2) {
    console.log('Error unexpected arguments\n' + 
                'Usage: node postinstall-ios.js\n');
    process.exit(1);
}

//--------------------------------------
// Useful functions
//--------------------------------------
var fs = require('fs');
var exec = require('child_process').exec;

var extractAppName = function() {
    var config = fs.readFileSync('config.xml', 'utf8');
    return config.match(/\<name\>(.*)\<\/name\>/)[1];
}

var copyFile = function(srcPath, targetPath) {
    fs.createReadStream(srcPath).pipe(fs.createWriteStream(targetPath));
};

//--------------------------------------
// Doing actual post installation work
//--------------------------------------
console.log('Extracting appName');
var appName = extractAppName();
console.log('appName-->' + appName);
console.log('Copying AppDelegate');
copyFile('plugins/com.salesforce/ios/Classes/AppDelegate.h', 'platforms/ios/' + appName + '/Classes/AppDelegate.h');
copyFile('plugins/com.salesforce/ios/Classes/AppDelegate.m', 'platforms/ios/' + appName + '/Classes/AppDelegate.m');
