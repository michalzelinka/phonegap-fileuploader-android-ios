//
//  FileUploader.m
//
//  Created by Matt Kane on 14/01/2011.
//  Copyright 2011 Matt Kane. All rights reserved.
//  Additional Android/iOS multiplatform stuff by Michal Zelinka 2012
//

#import "FileUploader.h"


@implementation FileUploader
@synthesize callbackID;

- (void) upload:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options 
{
	
	self.callbackID = [arguments pop];
	
	if([arguments count] < 2) {
		[self writeJavascript:[[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Argument count error"] toErrorCallbackString:callbackID]];
		return;
	}
	
	NSString* server = [arguments objectAtIndex:0];
	NSURL* file = [NSURL fileURLWithPath:[arguments objectAtIndex:1] isDirectory:NO];
	NSString* fileKey = nil;
	NSString* fileName = nil;
	NSString* mimeType = nil;
	
	if ([arguments count] > 2)
		fileKey = [arguments objectAtIndex:2];
	if ([arguments count] > 3)
		fileName = [arguments objectAtIndex:3];
	if ([arguments count] > 4)
		mimeType = [arguments objectAtIndex:4];
	
	[self uploadFile:file toServer:server withParams:options fileKey:fileKey fileName:fileName mimeType:mimeType];
	
}

- (void) uploadByUri:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options 
{
	
	self.callbackID = [arguments pop];

	if([arguments count] < 2) {
		[self writeJavascript:[[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Argument count error"] toErrorCallbackString:callbackID]];
		return;
	}

	NSString* server = [arguments objectAtIndex:0];
	NSURL* file = [NSURL URLWithString:[arguments objectAtIndex:1]];
	NSString* fileKey = nil;
	NSString* fileName = nil;
	NSString* mimeType = nil;

	if ([arguments count] > 2)
		fileKey = [arguments objectAtIndex:2];
	if ([arguments count] > 3)
		fileName = [arguments objectAtIndex:3];
	if ([arguments count] > 4)
		mimeType = [arguments objectAtIndex:4];
	
	[self uploadFile:file toServer:server withParams:options fileKey:fileKey fileName:fileName mimeType:mimeType];
	
}

- (void) uploadFile:(NSURL*)file toServer:(NSString*)server withParams:(NSMutableDictionary*)params fileKey:(NSString*)fileKey fileName:(NSString*)fileName mimeType:(NSString*)mimeType
{	
	
	if (![file isFileURL]) {
		[self writeJavascript:[[CDVPluginResult resultWithStatus:CDVCommandStatus_MALFORMED_URL_EXCEPTION messageAsString:@"Malformed URL exception"] toErrorCallbackString:callbackID]];
		return;
	}
	
	if(!fileName) {
		fileName = @"image.jpg";	
	}
	
	if(!mimeType) {
		mimeType = @"image/jpeg";	
	}
	
	if(!fileKey) {
		fileKey = @"file";	
	}
	NSURL *url = [NSURL URLWithString:server];

	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	[req setHTTPMethod:@"POST"];
	
	if([params objectForKey:@"__cookie"]) {
		[req setValue:[params objectForKey:@"__cookie"] forHTTPHeaderField:@"Cookie"];
		[params removeObjectForKey:@"__cookie"];
		[req setHTTPShouldHandleCookies:NO];
	}
	
	NSString *boundary = @"*****com.example.formBoundary";

	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	[req setValue:contentType forHTTPHeaderField:@"Content-type"];
	[req setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
	NSString* userAgent = [[self.webView request] valueForHTTPHeaderField:@"User-agent"];
	if(userAgent) {
		[req setValue: userAgent forHTTPHeaderField:@"User-agent"];
	}
	
	NSData *imageData = [NSData dataWithContentsOfURL:file];
	
	if(!imageData) {
		[self writeJavascript:[[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot open file"] toErrorCallbackString:callbackID]];
		return;
	}
	
	NSMutableData *postBody = [NSMutableData data];
	
	NSEnumerator *enumerator = [params keyEnumerator];
	id key;
	id val;
	while ((key = [enumerator nextObject])) {
		val = [params objectForKey:key];
		if(!val || val == [NSNull null]) {
			continue;	
		}
		[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[val dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}

	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileKey, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:imageData];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[req setHTTPBody:postBody];
	
	FileUploadDelegate* delegate = [[FileUploadDelegate alloc] init];
	delegate.command = self;
	
	[[NSURLConnection connectionWithRequest:req delegate:delegate] retain];
}

@end


@implementation FileUploadDelegate

@synthesize responseData, command;

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite 
{

	if (uploadIdx++ % 10 == 0) { 
	
		NSMutableDictionary* respObject = [[NSMutableDictionary alloc] init];
		[respObject setObject:@"PROGRESS" forKey:@"status"];
		[respObject setObject:[NSNumber numberWithInteger:totalBytesWritten] forKey:@"progress"];
		[respObject setObject:[NSNumber numberWithInteger:totalBytesExpectedToWrite] forKey:@"total"];
		
		CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:respObject];
		[pluginResult setKeepCallbackAsBool:TRUE]; // keep the callback alive for later uses
		
		[command writeJavascript:[pluginResult toSuccessCallbackString:command.callbackID]];

	}

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{

	NSString* response = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
	NSLog(@"Response: %@", response);
	
	NSMutableDictionary* respObject = [[NSMutableDictionary alloc] init];
	[respObject setObject:@"COMPLETE" forKey:@"status"];
// TODO: Find a way to provide these values
//	[respObject setObject:[NSNumber numberWithInt:100] forKey:@"progress"];
//	[respObject setObject:[NSNumber numberWithInt:100] forKey:@"total"];
	[respObject setObject:response forKey:@"result"];

	[command writeJavascript:[[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:respObject] toSuccessCallbackString:command.callbackID]];

	
	[connection autorelease];
	[self autorelease];

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{

	[command writeJavascript:[[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Connection failed"] toErrorCallbackString:command.callbackID]];
	[connection autorelease];
	[self autorelease];

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (id) init
{
    if (self = [super init]) {
		self.responseData = [NSMutableData data];
		uploadIdx = 0;
    }
    return self;
}

- (void) dealloc
{
	[responseData release];
	[command release];
    [super dealloc];
}

@end;
