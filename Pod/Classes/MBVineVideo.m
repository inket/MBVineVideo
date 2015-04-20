//
//  MBVineVideo.m
//  MBVineVideo
//
//  Created by inket on 4/8/15.
//  Copyright (c) 2015 inket. All rights reserved.
//

#import "MBVineVideo.h"

#define MBVineEmbedURL(x) ([NSURL URLWithString:[NSString stringWithFormat:@"https://vine.co/v/%@/embed/simple", x]])

@implementation MBVineVideo

NSError* vineFetchError(MBVineVideoFetchError code, NSError* originalError) {
    NSString* message = @"Unknown Error";
    
    switch (code) {
        case MBVineVideoFetchErrorInvalidURL: message = @"Invalid URL"; break;
        case MBVineVideoFetchErrorInvalidID: message = @"Invalid ID"; break;
        case MBVineVideoFetchErrorConnectionError:
            message = originalError.localizedDescription ?: @"Connection Error";
            break;
        case MBVineVideoFetchErrorParserError: message = @"Error parsing the Vine result"; break;
    }
    
    NSMutableDictionary *userInfo = @{NSLocalizedDescriptionKey: message}.mutableCopy;
    if (originalError) [userInfo setObject:originalError forKey:@"MBVineVideoOriginalError"];
    
    NSError *error = [NSError errorWithDomain:@"MBVineVideoErrorDomain" code:code userInfo:userInfo];
    
    return error;
}

+ (void)fetchVineFromURL:(NSString*)url completionHandler:(MBVineVideoCompletionHandler)handler {
    NSURL* vineURL = [NSURL URLWithString:url];
    BOOL validURL = [@"vine.co" isEqualToString:vineURL.host];
    if (!validURL) return handler(nil, vineFetchError(MBVineVideoFetchErrorInvalidURL, nil));
    
    NSMutableArray* pathComponents = [vineURL pathComponents].mutableCopy;
    NSString* vineIdentifier = nil;
    
    while (pathComponents.count > 1) {
        NSString* lastComponent = [pathComponents lastObject];
        [pathComponents removeLastObject];
        NSString* beforeLastComponent = [pathComponents lastObject];
        
        if ([beforeLastComponent isEqual:@"v"])
        {
            vineIdentifier = lastComponent;
            break;
        }
    }
    
    if (!vineIdentifier) return handler(nil, vineFetchError(MBVineVideoFetchErrorInvalidURL, nil));
    
    [MBVineVideo fetchVineFromID:vineIdentifier completionHandler:handler];
}

+ (void)fetchVineFromID:(NSString*)identifier completionHandler:(MBVineVideoCompletionHandler)handler {
    identifier = [identifier stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (identifier.length < 1) return handler(nil, vineFetchError(MBVineVideoFetchErrorInvalidID, nil));
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:MBVineEmbedURL(identifier)];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError)
                               {
                                   handler(nil, vineFetchError(MBVineVideoFetchErrorConnectionError, connectionError));
                               }
                               else
                               {
                                   NSError* error = nil;
                                   ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithData:data error:&error];
                                   if (error)
                                   {
                                       return handler(nil, vineFetchError(MBVineVideoFetchErrorParserError, error));
                                   }
                                   
                                   ONOXMLElement* configurationElement = [document firstChildWithCSS:@"#configuration"];
                                   
                                   if (!configurationElement)
                                   {
                                       return handler(nil, vineFetchError(MBVineVideoFetchErrorParserError, nil));
                                   }
                                   
                                   NSDictionary* configurationDictionary = [NSJSONSerialization JSONObjectWithData:[configurationElement.stringValue dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                                   if (error || ![configurationDictionary isKindOfClass:[NSDictionary class]])
                                   {
                                       return handler(nil, vineFetchError(MBVineVideoFetchErrorParserError, error));
                                   }
                                   
                                   
                                   MBVineVideo* vine = [[MBVineVideo alloc] initWithConfigurationDictionary:configurationDictionary];
                                   if (!vine)
                                   {
                                       return handler(nil, vineFetchError(MBVineVideoFetchErrorParserError, nil));
                                   }
                                   
                                   handler(vine, nil);
                               }
    }];
}

- (instancetype)initWithConfigurationDictionary:(NSDictionary*)configDict {
    self = [super init];
    
    if (self)
    {
        _title = [configDict valueForKeyPath:@"post.description"];
        _thumbnailURL = [NSURL URLWithString:[configDict valueForKeyPath:@"post.thumbnailUrl"]];
        _videoURL = ({
            NSURL* url = nil;
            
            for (NSDictionary* videoDict in [configDict valueForKeyPath:@"post.videoUrls"]) {
                url = [NSURL URLWithString:videoDict[@"videoUrl"]];
                if (url) break;
            }
            
            url;
        });
    }
    
    return self;
}

@end
