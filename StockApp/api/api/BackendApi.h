//
//  BackendApi.h
//  api
//
//  Created by Jarret on 1/31/15.
//  Copyright (c) 2015 Jarret. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackendApi : NSObject <NSStreamDelegate>

+ (void)initNetworkConnection;
+ (NSString *)signIn:(NSString*) username withPassword:(NSString*) password;
+ (BOOL)setUpAccount:(NSString *) username withPassword:(NSString *) password;

@end
