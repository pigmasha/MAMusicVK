//
//  MAControllerVK.h
//
//  Created by M on 04.05.14.
//  Copyright (c) 2014. All rights reserved.
//

@class MAVK;

@interface MAController (VKUtils)

- (BOOL)vkLogined;
- (void)vkLogin;
- (void)vkClose;
- (void)vkLogout;

- (void)vkSearch: (NSString*)text;

+ (BOOL)vkWebAnswer: (NSString*)str isClose: (BOOL)isClose;
- (void)vkWebError: (NSError *)error;

- (void)vkResult: (MAVK*)sender hasNext: (BOOL)hasNext;

@end
