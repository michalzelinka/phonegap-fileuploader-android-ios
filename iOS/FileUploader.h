//
//  FileUploader.h
//
//  Created by Matt Kane on 14/01/2011.
//  Copyright 2011 Matt Kane. All rights reserved.
//  Additional Android/iOS multiplatform stuff by Michal Zelinka 2012
//

#import <Foundation/Foundation.h>
#ifdef CORDOVA_FRAMEWORK
#import <CORDOVA/CDVPlugin.h>
#else
#import "CORDOVA/CDVPlugin.h"
#endif

@interface FileUploader : CDVPlugin {

	NSString* callbackID;
	
}

@property (nonatomic, copy) NSString* callbackID;

- (void) upload:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) uploadByUri:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) uploadFile:(NSURL*)file toServer:(NSString*)server withParams:(NSMutableDictionary*)params fileKey:(NSString*)fileKey fileName:(NSString*)fileName mimeType:(NSString*)mimeType;
@end


@interface FileUploadDelegate : NSObject {
	FileUploader* command;
	int uploadIdx;
}

@property (nonatomic, retain) NSMutableData* responseData;
@property (nonatomic, retain) FileUploader* command;

@end;
