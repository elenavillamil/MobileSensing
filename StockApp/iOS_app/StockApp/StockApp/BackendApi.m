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

#define DEBUG 0

+ (void)initNetworkConnection{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    //104.150.110.183 104.43.161.14
    
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"104.150.110.183", 8080, &readStream, &writeStream);
    
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
   
    #if DEBUG
    
        NSLog(@"stream event %lu", streamEvent);
    
    #endif
    
    switch (streamEvent) {
        case NSStreamEventOpenCompleted:
            #if DEBUG
            
                NSLog(@"Stream opened");
            
            #endif
            
            break;
            
        case NSStreamEventHasSpaceAvailable: {

            #if DEBUG
            
                NSLog(@"Available space");
            
            #endif
            
            break;
            
        }
            
        case NSStreamEventHasBytesAvailable:
            if (theStream == inputStream) {
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = (int)[inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            #if DEBUG
                            
                                NSLog(@"server said: %@", output);
                            #endif
                        }
                    }
                }
                
                [self sendString:@"Another Test"];
            }
            break;
            
        case NSStreamEventErrorOccurred:
            #if DEBUG
            
            NSLog(@"Can not connect to the host!");
         
            #endif
            
            break;
            
        case NSStreamEventEndEncountered:
            #if DEBUG
            
            NSLog(@"Closing stream...");
            
            #endif
            
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
            break;
            
        default: {
            #if DEBUG
            
            NSLog(@"Unknown event");
    
            #endif
        }
    }
}


+ (void)sendString:(NSString *)string {
    NSData *dataHere = [[NSData alloc] initWithData:[string dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSMutableData* data = [NSMutableData new];
    
    [data appendData:dataHere];
    
    [outputStream write:[dataHere bytes] maxLength:[data length]];
}

+ (NSString *)readString{
    static const size_t BUFFER_SIZE = 1024; // 1,024
    
    static uint8_t buffer[BUFFER_SIZE]; // avoid reallocation
    
    size_t amountRead = 0;
    
    NSMutableString * entireMessage = [NSMutableString new];
    
    do
    {
        amountRead = [inputStream read:buffer maxLength:BUFFER_SIZE];
        
        NSString * string = [[NSString alloc] initWithBytes:buffer length:amountRead encoding:NSASCIIStringEncoding];
        
        [entireMessage appendString:string];
        
    } while (amountRead == BUFFER_SIZE);
    
    return [NSString stringWithString:entireMessage];
}

+ (NSString *)signIn:(NSString*) username withPassword:(NSString*) password {
    if (!username || !password)
    {
        return @"";
    }
    
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

+ (BOOL)buyOrder:(NSString *) username withStockName:(NSString *) stockName withValue:(double) value withAmount:(size_t) amount {
    char function = (char)5;
    char username_size = (char)[username length];
    char stock_name_size = (char)[stockName length];
    
    NSString *valueStr = [[NSString alloc] initWithFormat:@"%f", value];
    NSString *amountStr = [[NSString alloc] initWithFormat:@"%zu", amount];
    
    char value_size = (char)[valueStr length];
    char amount_size = (char)[amountStr length];
    
    NSString* messageToSend = [NSString stringWithFormat:@"%c%c%@%c%@%c%zu%c%f", function, username_size, username, stock_name_size, stockName, amount_size, amount, value_size, value];

    [self sendString:messageToSend];

    NSString* readString = [self readString];

    BOOL returnValue = true;

    if ([readString isEqual:@"Buy failed"]) {
        returnValue = false;
    }   

    return true;
}

+ (BOOL)sellOrder:(NSString *) username withStockName:(NSString *) stockName withValue:(double) value withAmount:(size_t) amount {
    char function = (char)6;
    char username_size = (char)[username length];
    char stock_name_size = (char)[stockName length];
    
    NSString *valueStr = [[NSString alloc] initWithFormat:@"%f", value];
    NSString *amountStr = [[NSString alloc] initWithFormat:@"%zu", amount];
   
    char value_size = (char)[valueStr length];
    char amount_size = (char)[amountStr length];
    
    NSString* messageToSend = [NSString stringWithFormat:@"%c%c%@%c%@%c%zu%c%f", function, username_size, username, stock_name_size, stockName, amount_size, amount, value_size, value];

    [self sendString:messageToSend];

    NSString* readString = [self readString];

    BOOL returnValue = true;

    if ([readString isEqual:@"Sell failed"]) {
        returnValue = false;
    }   

    return true;
}

+ (NSInteger)currentAmountOfMoney:(NSString *) username {
    char function = (char)8;
    char usernameSize = (char)[username length];

    NSString* messageToSend = [NSString stringWithFormat:@"%c%c%@", function, usernameSize, username];

    [self sendString:messageToSend];
   
    NSString * readString = [self readString];
   
    if ([readString isEqual:@"-1"]) {
        return -1;
    }

    return [readString intValue];
}

+ (NSMutableArray*) getStockInfo:(NSMutableArray *)stocks{
    char function = (char)4;
    char numberOfStocs = (char)stocks.count;
    NSString* stocksString = @"";
    
    for (int i = 0; i < stocks.count; i++)
    {
        stocksString = [NSString stringWithFormat:@"%@%c%@", stocksString, (char)[stocks[i] length], stocks[i]];
    }
    
    NSString* message = [NSString stringWithFormat:@"%c%c%@", function, numberOfStocs, stocksString];

    [self sendString:message];
    
    NSString* response = [self readString];

    int numberStocks = [response characterAtIndex:0];
    int position = 1;
    NSMutableArray* words = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < numberStocks; i ++)
    {
        for (int j = 0; j < 4; j++)
        {
            int wordLength = [response characterAtIndex:position++];
            NSRange range = {position, wordLength};
            [words addObject:[response substringWithRange:range]];
            position += wordLength;
        }
    }
    
    for(int i =0; i < words.count; i++)
    {
        NSLog(@"%@", [words objectAtIndex:i]);
    }
    
    return words;
}

+ (NSMutableArray*) getHistory:(NSString *) username {
    char function = (char)7;
    char usernameSize = (char)[username length];
    
    NSString * messageToSend = [NSString stringWithFormat:@"%c%c%@", function, usernameSize, username];

    [self sendString:messageToSend];
    NSString* returnedString = [self readString];
    
    char amountOfTuplesAsStringLength = [returnedString characterAtIndex:0];
    
    if ([returnedString isEqualToString:@"Empty"])
    {
        return nil;
    }
    
    NSInteger amountOfTuples = [[returnedString substringWithRange:NSMakeRange(1, amountOfTuplesAsStringLength)] integerValue];
    
    size_t start = 1 + (int)amountOfTuplesAsStringLength;
    
    NSMutableArray * arrayToReturn = [NSMutableArray new];
    
    for (size_t index = 0; index < amountOfTuples; ++index) {
        char first_string_size = [returnedString characterAtIndex:start];
        NSString* first_string =[returnedString substringWithRange:NSMakeRange(start + 1, first_string_size)];
        
        // extra one to skip the length prefix
        start += first_string_size + 1;
        
        char second_string_size = [returnedString characterAtIndex:start];
        NSString* second_string =[returnedString substringWithRange:NSMakeRange(start + 1, second_string_size)];
        
        start += second_string_size + 1;
        
        char third_string_size = [returnedString characterAtIndex:start];
        NSString* third_string =[returnedString substringWithRange:NSMakeRange(start + 1, third_string_size)];
        
        start += third_string_size + 1;
        
        char fourth_string_size = [returnedString characterAtIndex:start];
        NSString* fourth_string =[returnedString substringWithRange:NSMakeRange(start + 1, fourth_string_size)];
        
        start += fourth_string_size + 1;
        
        char fifth_string_size = [returnedString characterAtIndex:start];
        NSString* fifth_string =[returnedString substringWithRange:NSMakeRange(start + 1, fifth_string_size)];
        
        start += fifth_string_size + 1;
        
        [arrayToReturn addObject:first_string];
        [arrayToReturn addObject:second_string];
        [arrayToReturn addObject:third_string];
        [arrayToReturn addObject:fourth_string];
        [arrayToReturn addObject:fifth_string];
    }
    
    return arrayToReturn;
}

+ (BOOL) addFavorite:(NSString *)username withStockName:(NSString *) stockName {
    char function = (char)10;
    char usernameSize = (char)[username length];
    char stockNameSize = (char)[stockName length];
                                
    NSString * messageToSend = [NSString stringWithFormat:@"%c%c%@%c%@", function, usernameSize, username, stockNameSize, stockName];
    
    [self sendString:messageToSend];
    NSString* returnedString = [self readString];
    
    if ([returnedString isEqualToString:@"0"])
    {
        return false;
    }
    
    return true;
}

+ (NSMutableArray *) getFavorites:(NSString *)username {
    char function = (char)9;
    char usernameSize = (char)[username length];
    
    NSString * messageToSend = [NSString stringWithFormat:@"%c%c%@", function, usernameSize, username];
    
    [self sendString:messageToSend];
    NSString* returnedString = [self readString];
    
    NSMutableArray * returnArray = [NSMutableArray new];
    
    char amountOfStrings = (char)[returnedString characterAtIndex:0];
    
    size_t start = 1;
    
    for (size_t index = 0; index < amountOfStrings; ++index)
    {
        char first_string_size = [returnedString characterAtIndex:start];
        NSString* first_string =[returnedString substringWithRange:NSMakeRange(start + 1, first_string_size)];
        
        // extra one to skip the length prefix
        start += first_string_size + 1;
        
        [returnArray addObject:first_string];
    }
    
    return returnArray;
}

+ (BOOL) resetAccount:(NSString *)username {
    char function = (char)11;
    char usernameSize = (char)[username length];
    
    NSString * messageToSend = [NSString stringWithFormat:@"%c%c%@", function, usernameSize, username];
    
    [self sendString:messageToSend];
    NSString* returnedString = [self readString];
    
    if ([returnedString isEqualToString:@"1"])
    {
        return true;
    }
    
    return false;
}

+ (BOOL) removeFavorite:(NSString *)username withStockName:(NSString *)stockName {
    char routine = (char) 12; // remove_favorite code
    char usernameSize = (char)[username length];
    char stockNamesize = (char)[stockName length];
    
    NSString* messageToSend = [NSString stringWithFormat:@"%c%c%@%c%@", routine, usernameSize, username, stockNamesize, stockName];
    
    [self sendString:messageToSend];
    
    NSString* readString = [self readString];
    
    if ([readString isEqualToString:@"Remove Failed"])
    {
        return false;
    }
    
    return true;
}

@end
