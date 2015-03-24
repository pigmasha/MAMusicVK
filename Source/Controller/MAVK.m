//
//  MAVK.m
//
//  Created by M on 16.05.14.
//  Copyright (c) 2014. All rights reserved.
//

#import "MAVK.h"
#import "MAController.h"
#import "MAControllerVK.h"

@implementation MAVK

- (id)initWithType: (VKType)type
{
    if (self = [super init])
    {
        _type = type;
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

//---------------------------------------------------------------------------------
- (void)dealloc
{
    [_conn release];
    [_str release];
    [_nextStr release];
    [_items release];
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (void)act: (NSString*)str
{
    if (_type == VKSearch)
    {
        if (_str)
        {
            [str retain];
            [_nextStr release];
            _nextStr = str;
            return;
        }
        [str retain];
        [_str release];
        _str = str;
    } else {
        if (_isDwnl)
        {
            _nonActual = YES;
            return;
        }
    }
    
    _nonActual = NO;
    _isDwnl = YES;
    if (_type == VKUrls)
    {
        [_str release];
        NSMutableString* str = [[NSMutableString alloc] init];
        for (NSDictionary* item in [MA_CONTROLLER listSongs])
        {
            [str appendFormat: (([str length]) ? @",%@_%@" : @"%@_%@"), [item objectForKey: SONG_OWNER], [item objectForKey: SONG_AID]];
        }
        for (NSDictionary* item in [MA_CONTROLLER songs])
        {
            [str appendFormat: (([str length]) ? @",%@_%@" : @"%@_%@"), [item objectForKey: SONG_OWNER], [item objectForKey: SONG_AID]];
        }
        if (![str length])
        {
            [str release];
            _str = nil;
            _isDwnl = NO;
            return;
        }
        _str = str;
    }
    [self performSelectorInBackground: @selector(onThread) withObject: nil];
}

//---------------------------------------------------------------------------------
- (void)onErr
{
    if (_type == VKSearch)
    {
        [_str release];
        _str = nil;
        [_nextStr release];
        _nextStr = nil;
    }
    _isErr = YES;
    _isDwnl = NO;
    
    [MA_CONTROLLER vkResult: self hasNext: NO];
}

//---------------------------------------------------------------------------------
- (void)onErrVK
{
    if (_noCheck)
    {
        [self onErr];
        [MA_CONTROLLER vkLogout];
        _noCheck = NO;
        return;
    }
    NSString* authLink = [[NSString alloc] initWithFormat: @"https://oauth.vk.com/authorize?client_id=%d&scope=audio&redirect_uri=https://oauth.vk.com/blank.html&display=mobile&v=5.9&response_type=token", VK_APP_ID];
    NSURL* url = [[NSURL alloc] initWithString: authLink];
    [authLink release];
    
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL: url];
    [url release];
    
    _ok = NO;
    _conn = [[NSURLConnection alloc] initWithRequest: req delegate: self];
    [req release];
    [_conn start];
}

//---------------------------------------------------------------------------------
- (void)onSucc
{
    _isErr = NO;
    _isDwnl = NO;
    
    if (_type == VKSearch)
    {
        if ([_nextStr isEqualToString: _str])
        {
            [_nextStr release];
            _nextStr = nil;
        }
        [_str release];
        _str = nil;
    }
    [MA_CONTROLLER vkResult: self hasNext: (_type == VKSearch) ? (_nextStr != nil) : _nonActual];
    
    if (_type == VKSearch)
    {
        if (_nextStr) [self act: _nextStr];
    } else {
        if (_nonActual) [self act: nil];
    }
}

//---------------------------------------------------------------------------------
- (void)onThread
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey: SETT_VK_ID])
    {
        [self performSelectorOnMainThread: @selector(onErr) withObject: nil waitUntilDone: NO];
        return;
    }
    
    NSString* s = nil;
    
    switch (_type)
    {
        case VKSearch:
            s = [[NSString alloc] initWithFormat: @"https://api.vk.com/method/audio.search.xml?owner_id=%@&access_token=%@&count=200&q=%@",
                 [[NSUserDefaults standardUserDefaults] objectForKey: SETT_VK_ID],
                 [[NSUserDefaults standardUserDefaults] objectForKey: SETT_VK_TOKEN], _str, nil];
            break;
        case VKUrls:
            s = [[NSString alloc] initWithFormat: @"https://api.vk.com/method/audio.getById.xml?owner_id=%@&access_token=%@&audios=%@",
                 [[NSUserDefaults standardUserDefaults] objectForKey: SETT_VK_ID],
                 [[NSUserDefaults standardUserDefaults] objectForKey: SETT_VK_TOKEN], _str, nil];
            break;
    }
    
    NSURL* url = [[NSURL alloc] initWithString: [s stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    [s release];
    
    NSMutableData* data = [[NSMutableData alloc] initWithContentsOfURL: url];
    [url release];
    
    if (![data length])
    {
        _noCheck = NO;
        [data release];
        [self performSelectorOnMainThread: @selector(onErr) withObject: nil waitUntilDone: NO];
        return;
    }
    
    char* bytes = [data mutableBytes];
    bytes[[data length] - 1] = '\0';
    
    if (strstr(bytes, "<error>") || !strstr(bytes, "</respo"))
    {
        [data release];
        [self performSelectorOnMainThread: @selector(onErrVK) withObject: nil waitUntilDone: NO];
        return;
    }
    _noCheck = NO;
    
    [MAVK parseVKSongs: bytes to: _items];
    [data release];
    [self performSelectorOnMainThread: @selector(onSucc) withObject: nil waitUntilDone: NO];
}

//---------------------------------------------------------------------------------
- (void)vkConnFinish
{
    [_conn release];
    _conn = nil;
    _isDwnl = NO;
    _isErr = NO;
    
    if (_ok)
    {
        _noCheck = YES;
        if (_type == VKSearch)
        {
            if (_nextStr)
            {
                [self act: _nextStr];
            } else {
                if (_str)
                {
                    _nextStr = _str;
                    _str = nil;
                    [self act: _nextStr];
                }
            }
        } else {
            [self act: nil];
        }
    } else {
        [MA_CONTROLLER vkLogout];
    }
}

//---------------------------------------------------------------------------------
// <NSURLConnectionDataDelegate>
//---------------------------------------------------------------------------------
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSHTTPURLResponse *)response
{
    if ([MAController vkWebAnswer: request.URL.absoluteString isClose: NO])
    {
        _ok = YES;
    }
    return request;
}

//---------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self performSelectorOnMainThread: @selector(vkConnFinish) withObject: nil waitUntilDone: NO];
}

//---------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self performSelectorOnMainThread: @selector(vkConnFinish) withObject: nil waitUntilDone: NO];
}

//---------------------------------------------------------------------------------

#define TAG_VAL(__v, __t1, __t2) \
{ \
char* p2 = strstr(bytesPos, __t2); \
if (p2) \
{ \
p2[0] = '\0'; \
char* p3 = strstr(bytesPos, __t1); \
if (p3) __v = [[NSString alloc] initWithUTF8String: p3 + strlen(__t1)]; \
p2[0] = '<'; \
} \
}

//---------------------------------------------------------------------------------
+ (void)parseVKSongs: (char*)bytes to: (NSMutableArray*)items
{
    [items removeAllObjects];
    
    char* bytesPos = bytes;
    while (YES)
    {
        char* p1 = strstr(bytesPos, "</audio>");
        if (!p1) break;
        p1[0] = '\0';
        
        NSString* aid = nil;
        TAG_VAL(aid, "<aid>", "</aid>");
        
        NSString* owner = nil;
        TAG_VAL(owner, "<owner_id>", "</owner_id>");
        
        NSString* artist = nil;
        TAG_VAL(artist, "<artist>", "</artist>");
        
        NSString* title = nil;
        TAG_VAL(title, "<title>", "</title>");
        
        NSString* duration = nil;
        TAG_VAL(duration, "<duration>", "</duration>");
        
        NSString* url = nil;
        TAG_VAL(url, "<url>", "</url>");
        
        
        if (aid && owner)
        {
            NSNumber* nAid = [[NSNumber alloc] initWithLong: [aid intValue]];
            NSNumber* nDur = [[NSNumber alloc] initWithInt: [duration intValue]];
            NSString* durStr = [[NSString alloc] initWithFormat: @"%d:%02d", [nDur intValue] / 60, [nDur intValue] % 60];
            NSDictionary* i = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                               nAid, SONG_AID,
                               (artist) ? artist : @"", SONG_ARTIST,
                               (title) ? title : @"", SONG_TITLE,
                               nDur, SONG_DUR,
                               durStr, SONG_DUR_STR,
                               owner, SONG_OWNER,
                               url, SONG_URL, nil];
            [durStr release];
            [nAid release];
            [nDur release];
            [items addObject: i];
            [i release];
        }
        [aid release];
        [owner release];
        [artist release];
        [title release];
        [duration release];
        [url release];
        
        bytesPos = p1 + 1;
    }
}

@end
