Steps to use that plugin
------------------------

<pre>
sudo npm install -g cordova

cordova create TestApp
cd TestApp
cordova platform add android
cordova plugin add https://github.com/wmathurin/SalesforceMobileSDK-CordovaPlugin
node ./plugins/com.salesforce/tools/postinstall.js
cordova build
cordova emulate android
</pre>


Steps to update android/shared used by plugin
---------------------------------------------
Check that bower.json is pointing to the branch you are interested in
Run

<pre>
./tools/update.sh
</pre>
