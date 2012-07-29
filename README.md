
# FileUploader

FileUploader PhoneGap/Cordova plugin for file uploading. This is a multiplatform version merged from two separate code bases (original sources available at [PhoneGap Plugins][1] repository).

[1]: https://github.com/phonegap/phonegap-plugins/

The code is currently tested with **Cordova 1.9.0**, but it should easily work on newer (or even older) versions of Cordova (maybe event PhoneGap).

Available online on my [BitBucket repository here][2] or [here][3].

[2]: http://mercury.misacek.net
[3]: https://bitbucket.org/misacek/phonegap-fileuploader-android-ios

## iOS Howto

1. Move both *FileUploader.h* and *FileUploader.m* to **Plugins** folder in your project home directory via Finder.
2. In Xcode, add both files into the **Plugins** group of your project.
3. Open included *Cordova.plist* and add provided values in **Plugins** section and **ExternalHosts** section (optional, depends on your needs) to the one included in your project. Do *NOT* replace your Cordova.plist with the one provided, just transfer the values.
4. Move the provided *fileuploader.js* to your **www** folder, also include it in your application code. See the included *index.html* for more info how to use it.
5. Compile, run and **ENJOY**!

## Android Howto

1. Move the provided *FileUploader.java* into your project's **src** directory, by making subfolders according to your needs (the plugin uses package **com.example** by default, so you should put it into **src/com/example/**).
2. Check your project if it included the newly added class (tested mainly with default Eclipse environment, pressing **F5** is usually enough to reload project contents).
3. Use the included *plugins.xml* to edit your own **res/xml/plugins.xml** file by including the provided plugin line. Also fix your class name if it differs from default (which identifies as *com.example.FileUploader*). Also check your **res/xml/cordova.xml** to allow access to hosts you need.
4. Move the provided *fileuploader.js* to your **www** folder, also include it in your application code. See the included *index.html* for more info how to use it.
5. Compile, run and **ENJOY**!

## Notes

### iOS quirks
- *PROGRESS* and *TOTAL* values are not returned to *callback* function when download is finished. Current code doesn't provide these values, but I'm working on it.
- Other values returned to your JS code via callbacks should be same on both platforms, but there's still a possibility I'm mistaken :) If you find any difference, please contact me so I can quickly fix it.
- iOS code has also been ported pretty quickly and hasn't been tested heavily yet.

## History

- **2012-07-29** Initial commit

## License

Copyright (c) 2012 Michal Zelinka.

See the included LICENCE file for licence details.
