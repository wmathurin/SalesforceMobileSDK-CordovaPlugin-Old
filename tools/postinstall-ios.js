//--------------------------------------
// Reading arguments from command line
//--------------------------------------
if (process.argv.length < 3) {
    console.log('Error missing arguments\n' + 
                'Usage: node postinstall-ios.js  <AppName>\n'); // XXX we could figure out the AppName
    process.exit(1);
}
var appName = process.argv[2];

//--------------------------------------
// Useful functions
//--------------------------------------
var fs = require('fs');
var exec = require('child_process').exec;

var copyFile = function(srcPath, targetPath) {
    fs.createReadStream(srcPath).pipe(fs.createWriteStream(targetPath));
};

//--------------------------------------
// Doing actual post installation work
//--------------------------------------
console.log('Copying AppDelegate');
copyFile('plugins/com.salesforce/ios/Template/Classes/AppDelegate.h', 'platforms/ios/' + AppName + 'Classes/');
copyFile('plugins/com.salesforce/ios/Template/Classes/AppDelegate.m', 'platforms/ios/' + AppName + 'Classes/');
