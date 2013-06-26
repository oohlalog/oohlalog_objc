//
//  OohlalogLogger.h
//  oohlalog
//
//  Created by David Estes on 3/3/13.
//  Copyright (c) 2013 David Estes. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef OohlalogHost
#define OohlalogHost @"api.oohlalog.com"
#endif
#ifndef OohlalogPort
#define OohlalogPort 80
#endif

@interface OohlalogLogger : NSObject {
    NSMutableArray *logBuffer;
    NSInteger bufferSize;
    NSString *apiKey;
    BOOL finished;
//    NSThread *sour
    NSThread *loggerThread;
}
-(id)initWithBufferSize:(NSInteger)_bufferSize apiKey:(NSString *)_apiKey;

-(void)sendWithLogLevel:(NSInteger) logLevel message:(NSString*)message category:(NSString*)category subcategory:(NSString*)subcategory details:(NSString*)details;
-(void)incrementCounter: (NSString *)code withValue:(NSUInteger) counter;

@property(nonatomic, assign) NSInteger bufferSize;
@property(nonatomic, retain) NSString* apiKey;
@property(nonatomic, retain) NSThread *loggerThread;

@end
