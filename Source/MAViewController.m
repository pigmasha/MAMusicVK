//
//  MAViewController.m
//  MAMusicVK
//
//  Created by M on 29.11.14.
//  Copyright (c) 2014. All rights reserved.
//

#import "MAViewController.h"
#import "MAController.h"
#import "MAConstants.h"
#import "MASongCell.h"
#import "MAControllerVK.h"
#import "MAConstants.h"
#import "MASongCell.h"
#import "MATableView.h"
#import "MACells.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MAPlayerView.h"

#define SONG_IMG_X 52

typedef enum
{
    MAViewNone,
    MAViewVKLogin, // login table
    MAViewVKWeb,  // web view with VK login form
    MAViewSongs,  // songs only
    MAViewLists   // songs & lists
} MAViewMode;

@interface MAViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIWebViewDelegate>
{
    MAViewMode _mode;
    UITableView* _table;
    UIWebView* _wv;
    
    MAPlayerView* _playV;
    UISegmentedControl* _segm;
    UISearchBar* _searchBar;
    
    BOOL _isList;
    
    NSDictionary* _aids; // link to [MA_CONTROLLER aids]
    NSString* _lastSearch;
    
    UIActivityIndicatorView* _act;
}
@end

//=================================================================================

@implementation MAViewController

- (void)loadView
{
    [super loadView];
    if ([self respondsToSelector: @selector(setEdgesForExtendedLayout:)]) [self setEdgesForExtendedLayout: UIRectEdgeNone];
    
    self.title = LSTR(@"V_Title");
    
    _aids = [MA_CONTROLLER aids];
    
    _searchBar = [[UISearchBar alloc] init];
    [_searchBar sizeToFit];
    _searchBar.delegate = self;
    _searchBar.returnKeyType = UIReturnKeyDone;
    if ([[NSUserDefaults standardUserDefaults] objectForKey: SETT_SRCH]) _searchBar.text = [[NSUserDefaults standardUserDefaults] objectForKey: SETT_SRCH];
    
    [self reloadData];
}

//---------------------------------------------------------------------------------
- (void)dealloc
{
    [_searchBar  release];
    [_lastSearch release];
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (void)setMode: (MAViewMode)mode
{
    if (mode == _mode) return;
    
    _mode = mode;
    _isList = NO;
    
    [_table removeFromSuperview];
    _table = nil;
    [_wv removeFromSuperview];
    _wv = nil;
    [_playV removeFromSuperview];
    _playV = nil;
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.titleView = nil;
    _segm = nil;
    
    switch (_mode)
    {
        case MAViewVKLogin:
            _table = [[UITableView alloc] initWithFrame: self.view.bounds style: UITableViewStyleGrouped];
            _table.dataSource = self;
            _table.delegate = self;
            _table.autoresizingMask = SZ(Width) | SZ(Height);
            if ([_table respondsToSelector: @selector(setSeparatorInset:)]) _table.separatorInset = UIEdgeInsetsZero;
            [self.view addSubview: _table];
            [_table release];
            [_table reloadData];
            break;
            
        case MAViewVKWeb:
        {
            UIBarButtonItem* b = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target: self action: @selector(vkClose)];
            self.navigationItem.rightBarButtonItem = b;
            [b release];
            
            [MA_CONTROLLER vkLogin];
            _wv = [[UIWebView alloc] initWithFrame: self.view.bounds];
            _wv.autoresizingMask = SZ(Width) | SZ(Height);
            _wv.delegate = self;
            [self.view addSubview: _wv];
            [_wv release];
            
            NSString* authLink = [[NSString alloc] initWithFormat: @"https://oauth.vk.com/authorize?client_id=%d&scope=audio&redirect_uri=https://oauth.vk.com/blank.html&display=mobile&v=5.9&response_type=token", VK_APP_ID];
            NSURL* url = [[NSURL alloc] initWithString: authLink];
            [authLink release];
            
            NSURLRequest* req = [[NSURLRequest alloc] initWithURL: url];
            [url release];
            
            [_wv loadRequest: req];
            [req release];
            break;
        }
            
        case MAViewLists:
        case MAViewSongs:
        {
            _playV = [[MAPlayerView alloc] initWithFrame: CGRectMake(0, self.view.bounds.size.height - PLAY_PANEL_H, self.view.bounds.size.width, PLAY_PANEL_H)];
            [self.view addSubview: _playV];
            [_playV release];
            
            _table = [[MATableView alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - PLAY_PANEL_H) style: UITableViewStylePlain];
            _table.dataSource = self;
            _table.delegate = self;
            _table.tableHeaderView = _searchBar;
            _table.autoresizingMask = SZ(Width) | SZ(Height);
            if ([_table respondsToSelector: @selector(setSeparatorInset:)]) _table.separatorInset = UIEdgeInsetsZero;
            [self.view addSubview: _table];
            [_table release];
            [_table reloadData];
            
            if (_mode == MAViewLists)
            {
                NSArray* items = [[NSArray alloc] initWithObjects: @"Songs", [[MA_CONTROLLER list] objectForKey: LIST_NAME], nil];
                _segm = [[UISegmentedControl alloc] initWithItems: items];
                [items release];
                _segm.selectedSegmentIndex = 0;
                [_segm addTarget: self action: @selector(onSegment) forControlEvents: UIControlEventValueChanged];
                self.navigationItem.titleView = _segm;
                [_segm release];
            }
            break;
        }
            
        default: break;
    }
    
}

//---------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem* b = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"sett"] style: UIBarButtonItemStylePlain target: MA_CONTROLLER action: @selector(onSett)];
    self.navigationItem.leftBarButtonItem = b;
    [b release];
}

//---------------------------------------------------------------------------------
- (void)onSegment
{
    _isList = (_segm.selectedSegmentIndex == 1);
    _table.tableHeaderView = (_isList) ? nil : _searchBar;
    if (_isList)
    {
        UIBarButtonItem* b = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"icon_navbar_edit"] style: UIBarButtonItemStylePlain target: MA_CONTROLLER action: @selector(onLists)];
        self.navigationItem.rightBarButtonItem = b;
        [b release];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    [_table reloadData];
}

//---------------------------------------------------------------------------------
- (void)reloadData
{
    if (![MA_CONTROLLER vkLogined])
    {
        if (_mode != MAViewVKLogin && _mode != MAViewVKWeb) [self setMode: MAViewVKLogin];
        return;
    }
    MAViewMode m = SETT_BOOL_VAL(SETT_USE_LISTS) ? MAViewLists : MAViewSongs;
    if (m == _mode)
    {
        if (_segm) [_segm setTitle: [[MA_CONTROLLER list] objectForKey: LIST_NAME] forSegmentAtIndex: 1];
        [_table reloadData];
    } else {
        [self setMode: SETT_BOOL_VAL(SETT_USE_LISTS) ? MAViewLists : MAViewSongs];
    }
}

//---------------------------------------------------------------------------------
- (BOOL)isList
{
    return (_mode == MAViewLists && _isList);
}

//---------------------------------------------------------------------------------
- (void)setLoading: (BOOL)flag
{
    if (flag)
    {
        if (!_act)
        {
            _act = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
            CGRect r = _act.bounds;
            r.origin.y = _searchBar.bounds.size.height + (SONG_ROW_H - r.size.height) / 2;
            r.origin.x = self.view.bounds.size.width - r.size.width - 15;
            _act.backgroundColor = [UIColor colorWithWhite: 1 alpha: 0.8];
            _act.frame = r;
            _act.autoresizingMask = SZ_M(Left);
            [self.view addSubview: _act];
            [_act startAnimating];
            [_act release];
        }
    } else {
        if (_act)
        {
            [_act stopAnimating];
            [_act removeFromSuperview];
            _act = nil;
        }
    }
}

#define MA_VIEW_CELL_ID @"V1"

//---------------------------------------------------------------------------------
// <UITableViewDataSource>
//---------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (_mode)
    {
        case MAViewVKLogin: return 2;
        case MAViewSongs: return [[MA_CONTROLLER songs] count];
        case MAViewLists: return (_isList) ? [[MA_CONTROLLER listSongs] count] : [[MA_CONTROLLER songs] count];
        default: break;
    }
    return 0;
}

//---------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_mode == MAViewVKLogin)
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: MA_VIEW_CELL_ID];
        if (!cell)
        {
            cell = [[[MAZeroCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: MA_VIEW_CELL_ID] autorelease];
            cell.textLabel.numberOfLines = 0;
        }
        
        if (indexPath.row == 0)
        {
            cell.textLabel.text = LSTR(@"V_VKLogin");
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textColor = [UIColor blackColor];
        } else {
            cell.textLabel.text = LSTR(@"V_VKLoginBt");
            cell.selectionStyle = CELL_SEL_DEF;
            cell.textLabel.textColor = [MAController btTextColor];
        }
        return cell;
    }
    if (_mode == MAViewLists && _isList)
    {
        NSNumber* cur = [[MA_CONTROLLER listSong] objectForKey: SONG_AID];
        
        NSDictionary* d = [[MA_CONTROLLER listSongs] objectAtIndex: indexPath.row];
        
        if (cur && [[d objectForKey: SONG_AID] isEqualToNumber: cur])
        {
            [[MASongRCellCur sharedInstance] setItem: d];
            return [MASongRCellCur sharedInstance];
        }
        
        MASongRCell* cell = [tableView dequeueReusableCellWithIdentifier: [MASongRCell identifier]];
        if (!cell) cell = [[[MASongRCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: [MASongRCell identifier]] autorelease];
        [cell setItem: d];
        
        return cell;
    }
    
    NSNumber* cur = [[MA_CONTROLLER song] objectForKey: SONG_AID];
    
    NSDictionary* d = [[MA_CONTROLLER songs] objectAtIndex: indexPath.row];
    
    if (cur && [[d objectForKey: SONG_AID] isEqualToNumber: cur])
    {
        [[MASongCellCur sharedInstance] setItem: d isChk: ([_aids objectForKey: [d objectForKey: SONG_AID]]) ? YES : NO];
        return [MASongCellCur sharedInstance];
    }
    
    MASongCell* cell = [tableView dequeueReusableCellWithIdentifier: [MASongCell identifier]];
    if (!cell) cell = [[[MASongCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: [MASongCell identifier]] autorelease];
    [cell setItem: d isChk: ([_aids objectForKey: [d objectForKey: SONG_AID]]) ? YES : NO];
    
    return cell;
}

//---------------------------------------------------------------------------------
// <UITableViewDelegate>
//---------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_mode == MAViewSongs || _mode == MAViewLists) return SONG_ROW_H;
    return (indexPath.row == 0) ? 64 : tableView.rowHeight;
}

//---------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_searchBar resignFirstResponder];
    
    if (_mode == MAViewVKLogin)
    {
        if (indexPath.row) [self setMode: MAViewVKWeb];
        return;
    }
    
    if (_mode == MAViewLists && _isList)
    {
        [MA_CONTROLLER playSong: [[MA_CONTROLLER listSongs] objectAtIndex: indexPath.row] isList: YES];
        return;
    }
    
    [_searchBar resignFirstResponder];
    
    NSDictionary* d = [[MA_CONTROLLER songs] objectAtIndex: indexPath.row];
    
    if ([(MATableView*)_table lastX] < SONG_IMG_X)
    {
        [MA_CONTROLLER onSong: d];
        [tableView reloadData];
    } else {
        [MA_CONTROLLER playSong: d isList: NO];
    }
}

//---------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (_mode == MAViewLists && _isList) ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

//---------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [MA_CONTROLLER onSong: [[MA_CONTROLLER listSongs] objectAtIndex: indexPath.row] isAdd: NO];
        [_table reloadData];
    }
}

//---------------------------------------------------------------------------------
// Search
//---------------------------------------------------------------------------------
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([_lastSearch isEqualToString: searchText]) return NO;
    [_lastSearch release];
    _lastSearch = [[NSString alloc] initWithString: searchText];
    if (![_lastSearch length])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey: SETT_SRCH];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject: _lastSearch forKey: SETT_SRCH];
    
    [_table reloadData];
    [MA_CONTROLLER vkSearch: _lastSearch];
}

//---------------------------------------------------------------------------------
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
}

//---------------------------------------------------------------------------------
// VK
//---------------------------------------------------------------------------------
- (void)vkClose
{
    _mode = MAViewNone;
    [self reloadData];
}

//---------------------------------------------------------------------------------
// <UIWebViewDelegate>
//---------------------------------------------------------------------------------
- (void)webViewDidFinishLoad: (UIWebView *)webView
{
    [MAController vkWebAnswer: _wv.request.URL.absoluteString isClose: YES];
}

//---------------------------------------------------------------------------------
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MA_CONTROLLER vkWebError: error];
}

@end
