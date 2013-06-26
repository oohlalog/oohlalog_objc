//
//  OohlalogLogger.m
//  oohlalog
//
//  Created by David Estes on 3/3/13.
//  Copyright (c) 2013 David Estes. All rights reserved.
//

#import "OohlalogLogger.h"

@implementation OohlalogLogger
@synthesize bufferSize, apiKey, loggerThread;

-(id)initWithBufferSize:(NSInteger)_bufferSize apiKey:(NSString *)_apiKey {
    
    if((self = [super init]))
    {
        self.bufferSize = _bufferSize;
        self.apiKey = _apiKey;
        self.loggerThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadLoop) object:nil];
    }
    return self;
}

-(void)sendWithLogLevel:(NSInteger) logLevel message:(NSString*)message category:(NSString*)category subcategory:(NSString*)subcategory details:(NSString*)details {
    NSDictionary *logEntry = [[NSDictionary alloc] initWithObjectsAndKeys:@"level",logLevel,@"message", message, @"category", category, @"subcategory", subcategory, @"details", details, @"timestamp", [NSDate alloc], nil];
    [logBuffer addObject:logEntry];
    
    [self checkBuffer];
}

-(void)incrementCounter: (NSString *)code withValue:(NSUInteger) counter {

    
    NSString *requestString = [[NSString alloc] initWithFormat:@"http://%@:%d/api/counter/increment?apiKey=%@&code=%@&incr=%d",OohlalogHost,OohlalogPort,[self.apiKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],code, counter];
    NSURL *url = [NSURL URLWithString:requestString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setHTTPMethod:@"POST"];

    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void) checkBuffer {
    if([logBuffer count] > bufferSize) {
        [self.loggerThread performSelector:@selector(flushBuffer)];
        [NSThread detachNewThreadSelector:@selector(flushBuffer) toTarget:self withObject:nil];
    }
}

-(void)threadLoop {
    while(true) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)flushBuffer {
    NSMutableArray *payloadArray = [[NSMutableArray alloc] init];
    while([logBuffer count] > 0) {
        NSDictionary *logEntry = (NSDictionary *)[logBuffer objectAtIndex:[logBuffer count] - 1];
        [logBuffer removeObject:logEntry];
        [payloadArray addObject:logEntry];
    }

    NSString *requestString = [[NSString alloc] initWithFormat:@"http://%@:%d/logger/save?apiKey=%@",OohlalogHost,OohlalogPort,[self.apiKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:requestString];

    NSData *_requestData = [NSJSONSerialization dataWithJSONObject:payloadArray options:nil error:nil];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:_requestData];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

@end
