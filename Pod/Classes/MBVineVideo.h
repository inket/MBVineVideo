//
//  MBVineVideo.h
//  MBVineVideo
//
//  Created by inket on 4/8/15.
//  Copyright (c) 2015 inket. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Ono/Ono.h>

@interface MBVineVideo : NSObject

typedef enum : NSUInteger {
    MBVineVideoFetchErrorInvalidURL,
    MBVineVideoFetchErrorInvalidID,
    MBVineVideoFetchErrorConnectionError,
    MBVineVideoFetchErrorParserError
} MBVineVideoFetchError;

typedef void (^MBVineVideoCompletionHandler) (MBVineVideo* vine, NSError *error);

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSURL* thumbnailURL;
@property (nonatomic, strong) NSURL* videoURL;

+ (void)fetchVineFromURL:(NSString*)url completionHandler:(MBVineVideoCompletionHandler)handler;
+ (void)fetchVineFromID:(NSString*)identifier completionHandler:(MBVineVideoCompletionHandler)handler;

@end
