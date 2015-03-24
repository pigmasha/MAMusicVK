//
//  MAAddController.m
//  MAMusicVK
//
//  Created by M on 05.03.15.
//  Copyright (c) 2015. All rights reserved.
//

#import "MAAddController.h"
#import "MAController.h"
#import "MACells.h"

@interface MAAddController ()
{
    MAInputCell* _cellN;
}

@end

//=================================================================================

@implementation MAAddController

//---------------------------------------------------------------------------------
- (void)loadView
{
    [super loadView];
    self.title = LSTR(@"Add_Title");
    _cellN = [[MAInputCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: nil];
    [_cellN input].placeholder = LSTR(@"Add_Holder");
}

//---------------------------------------------------------------------------------
- (void)dealloc
{
    [_cellN release];
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* b = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave target: self action: @selector(onOk)];
    self.navigationItem.rightBarButtonItem = b;
    [b release];
}

//---------------------------------------------------------------------------------
- (void)onOk
{
    [MA_CONTROLLER addList: [_cellN input].text];
    [self.presentingViewController dismissViewControllerAnimated: YES completion: NULL];
}

//---------------------------------------------------------------------------------
// <UITableViewDataSource>
//---------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//---------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#define MA_LISTS_CELL_ID @"L1"

//---------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellN;
}

@end

