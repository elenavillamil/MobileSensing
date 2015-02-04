//
//  BackendApi.m
//  api
//
//  Created by Jarret on 1/31/15.
//  Copyright (c) 2015 Jarret. All rights reserved.
//

#import "BackendApi.h"

@implementation BackendApi

NSMutableData *data;

NSInputStream *inputStream;
NSOutputStream *outputStream;

+ (void)initNetworkConnection{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"169.254.57.8", 8080, &readStream, &writeStream);
        
    inputStream = (__bridge NSInputStream *)readStream;
    inputStream.delegate = self;
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    
    outputStream = (__bridge NSOutputStream *)writeStream;
    outputStream.delegate = self;
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream open];
}

+ (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    NSLog(@"stream event %u", streamEvent);
    
    int byteIndex = 0;
    
    switch (streamEvent) {
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
            
        case NSStreamEventHasSpaceAvailable: {

            break;
            
        }
            
        case NSStreamEventHasBytesAvailable:
            if (theStream == inputStream) {
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            NSLog(@"server said: %@", output);
                        }
                    }
                }
                
                [self sendString:@"Another Test"];
            }
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"Can not connect to the host!");
            break;
            
        case NSStreamEventEndEncountered:
            NSLog(@"Closing stream...");
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
            break;
            
        default:
            NSLog(@"Unknown event");
    }
}


+ (void)sendString:(NSString *)string {
    NSData *dataHere = [[NSData alloc] initWithData:[string dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSMutableData* data = [NSMutableData new];
    
    [data appendData:dataHere];
    
    NSInteger amount_sent = [outputStream write:[dataHere bytes] maxLength:[data length]];
}

+ (NSString *)readString{
    static const size_t BUFFER_SIZE = 1024;
    
    static uint8_t buffer[BUFFER_SIZE]; // avoid reallocation
    
    size_t amount_read = [inputStream read:buffer maxLength:BUFFER_SIZE];
    
    return [[NSString alloc] initWithBytes:buffer length:amount_read encoding:NSASCIIStringEncoding];
}

+ (NSString *)signIn:(NSString*) username withPassword:(NSString*) password {
    char routine = (char) 2; // sign in code
    char usernameSize = (char)[username length];
    char passwordSize = (char)[password length];
    
    NSString* messageToSend = [NSString stringWithFormat:@"%c%c%@%c%@", routine, usernameSize, username, passwordSize, password];

    [self sendString:messageToSend];
    
    NSString* readString = [self readString];
    
    return readString;
}

+ (BOOL)setUpAccount:(NSString *) username withPassword:(NSString *) password {
    char routine = (char) 1; // set up account code.
    char usernameSize = (char)[username length];
    char passwordSize = (char)[password length];
    
    NSString* messageToSend = [NSString stringWithFormat:@"%c%c%@%c%@", routine, usernameSize, username, passwordSize, password];

    [self sendString:messageToSend];
    
    NSString* readString = [self readString];
    
    BOOL returnValue = false;
    
    if (![readString isEqual:@"Username already exists"]) {
        returnValue = true;
    }
    
    return returnValue;
}

+ (BOOL)buyOrder:(NSString *) username withStockName:(NSString *) stockName withValue:(size_t) value withAmount:(size_t) amount {
    char function = (char)5;
    char username_size = (char)[username length];
    char stock_name_size = (char)[stockName length];
    
    NSString *valueStr = [[NSString alloc] initWithFormat:@"%u", amount];
    NSString *amountStr = [[NSString alloc] initWithFormat:@"%u", value];
    
    char value_size = (char)[valueStr length];
    char amount_size = (char)[amountStr length];
    
    
}

@end
