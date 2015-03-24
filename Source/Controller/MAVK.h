//
//  MAVK.h
//
//  Created by M on 16.05.14.
//  Copyright (c) 2014. All rights reserved.
//

typedef enum
{
    VKSearch,
    VKUrls
} VKType;

@interface MAVK : NSObject
{
@public
    VKType _type;
    BOOL _noCheck;
    BOOL _ok;
    BOOL _isErr;
    BOOL _isDwnl;
    NSURLConnection* _conn;
    NSMutableArray* _items;
    
    NSString* _str; // for search
    NSString* _nextStr; // for search
    
    BOOL _nonActual;
}
- (id)initWithType: (VKType)type;
- (void)act: (NSString*)str;

@end
