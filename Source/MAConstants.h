//
//  MAConstants.h
//
//  Created by M on 10.02.14.
//  Copyright (c) 2014. All rights reserved.
//

// Create you application on vk.com and write it's id instead of 'YOUR_ID_HERE'
#define VK_APP_ID YOUR_ID_HERE

//---------------------------------------------------------------------------------

#define SZ(__s) UIViewAutoresizingFlexible ## __s
#define SZ_M(__s) UIViewAutoresizingFlexible ## __s ## Margin

#define LSTR(__str) NSLocalizedString(__str, nil)

#define CELL_SEL_DEF (([MAController osVer] > 6) ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleBlue)

//---------------------------------------------------------------------------------

#define SHOW_ALERT(__title, __msg) \
{ \
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: __title message: __msg delegate: nil cancelButtonTitle: LSTR(@"OK") otherButtonTitles:nil]; \
    [alert show]; \
    [alert release]; \
}

#define ADD_LABEL(__val, __x, __y, __w, __h, __mask, __fontSz, __isBold, __superview) \
    __val = [[UILabel alloc] initWithFrame: CGRectMake(__x, __y, __w, __h)]; \
    __val.autoresizingMask = __mask; \
    __val.backgroundColor = [UIColor clearColor]; \
    __val.font = (__isBold) ? [UIFont boldSystemFontOfSize: __fontSz] : [UIFont systemFontOfSize: __fontSz]; \
    [__superview addSubview: __val]; \
    [__val release];

#define SETT_BOOL_VAL(__name) (([[NSUserDefaults standardUserDefaults] integerForKey: __name]) ? ([[NSUserDefaults standardUserDefaults] integerForKey: __name] == 1) : (__name ## _DEF == 1))
#define SETT_SET_BOOL_VAL(__name, __val) [[NSUserDefaults standardUserDefaults] setInteger: (__val) ? 1 : 2 forKey: __name]

#define NUMBER_STR(__n, __str0, __str1, __str21, __str2, __res) \
{ \
    if (__n == 1) \
    { \
        __res = LSTR(__str1); \
    } else { \
        int nT = __n % 100; \
        if (nT > 10 && nT < 20) \
        { \
            __res = LSTR(__str0); \
        } else { \
            switch (nT % 10) { \
                case 1: __res = LSTR(__str21); break; \
                case 2: \
                case 3: \
                case 4: __res = LSTR(__str2); break; \
                default: __res = LSTR(__str0); break; \
            } \
        } \
    } \
}

/* settings */
// Current list
#define SETT_LIST @"L"
// search string
#define SETT_SRCH @"S"
// VK user id
#define SETT_VK_ID @"VKId"
// VK auth token
#define SETT_VK_TOKEN @"VKToken"

/* Bool settings stored as int: 0 - default, 1 - on, 2 - off */
// Show lists
#define SETT_USE_LISTS     @"UseL"
#define SETT_USE_LISTS_DEF 0

#define SETT_SQ     @"Sq"
#define SETT_SQ_DEF 1
