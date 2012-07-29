/**
 * Phonegap/Cordova File Upload plugin
 * Multiplatform iOS/Android version
 * Copyright (c) Matt Kane 2011
 * Additional Android/iOS multiplatform stuff by Michal Zelinka 2012
 *
 */
var FileUploader = function() { 

}


/**
 * Given a file:// or content:// url, uploads the file to the server as a multipart/mime request
 *
 * @param server URL of the server that will receive the file
 * @param file file:// or content:// uri of the file to upload
 * @param params Object with key: value params to send to the server
 * @param fileKey Parameter name of the file
 * @param fileName Filename to send to the server. Defaults to image.jpg
 * @param mimeType Mimetype of the uploaded file. Defaults to image/jpeg
 * @param callback Success callback. Passed the response data from the server as a string. Also receives progress messages during upload.
 * @param fail Error callback. Passed the error message.
 */
FileUploader.prototype.uploadByUri = function(server, file, params, fileKey, fileName, mimeType, callback, fail) {
	this._doUpload('uploadByUri', server, file, params, fileKey, fileName, mimeType, callback, fail);
};

/**
 * Given absolute path, uploads the file to the server as a multipart/mime request
 *
 * @param server URL of the server that will receive the file
 * @param file Absolute path of the file to upload
 * @param params Object with key: value params to send to the server
 * @param fileKey Parameter name of the file
 * @param fileName Filename to send to the server. Defaults to image.jpg
 * @param mimeType Mimetype of the uploaded file. Defaults to image/jpeg
 * @param callback Success callback. Passed the response data from the server as a string. Also receives progress messages during upload.
 * @param fail Error callback. Passed the error message.
 */
FileUploader.prototype.upload = function(server, file, params, fileKey, fileName, mimeType, callback, fail) {
	this._doUpload('upload', server, file, params, fileKey, fileName, mimeType, callback, fail);
};

FileUploader.prototype._doUpload = function(method, server, file, params, fileKey, fileName, mimeType, callback, fail) {
	if (!params) params = {};
	return Cordova.exec(callback, fail, 'FileUploader', method, [server, file, params, fileKey, fileName, mimeType]);
}

FileUploader.Status = {
	PROGRESS: "PROGRESS",
	COMPLETE: "COMPLETE"
}

Cordova.addConstructor(function()  {
	//////
	if(!window.plugins) {
		window.plugins = {};
	}
	window.plugins.fileUploader = new FileUploader();
	////// OR:
	//// / Cordova.addPlugin('fileUploader', new FileUploader());
	////// ?
});
