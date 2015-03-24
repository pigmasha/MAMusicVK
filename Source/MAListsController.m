//
//  MAListsController.m
//  MAMusicVK
//
//  Created by M on 05.03.15.
//  Copyright (c) 2015. All rights reserved.
//

#import "MAListsController.h"
#import "MAController.h"
#import "MACells.h"
#import "MAAddController.h"

@interface MAListsController ()
{
    MAInputCell* _cellN;
}

@end

//=================================================================================

@implementation MAListsController

//---------------------------------------------------------------------------------
- (void)loadView
{
    [super loadView];
    self.title = LSTR(@"L_Title");
    _cellN = [[MAInputCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: nil];
    [_cellN input].text = [[MA_CONTROLLER list] objectForKey: LIST_NAME];
    [[_cellN input] addTarget: self action: @selector(textFieldDidChange:) forControlEvents: UIControlEventEditingChanged];
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
    
    UIBarButtonItem* b = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"icon_navbar_cancel"] style: UIBarButtonItemStylePlain target:self action: @selector(onCancel)];
    self.navigationItem.leftBarButtonItem = b;
    [b release];
}

//---------------------------------------------------------------------------------
- (void)onCancel
{
    [self.presentingViewController dismissViewControllerAnimated: YES completion: NULL];
}

//---------------------------------------------------------------------------------
// <UITableViewDataSource>
//---------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

//---------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section < 2) ? 1 : [[MA_CONTROLLER lists] count];
}

//---------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? LSTR(@"L_Name") : ((section == 2) ? LSTR(@"L_History") : nil);
}

#define MA_LISTS_CELL_ID @"L1"

//---------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) return _cellN;
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: MA_LISTS_CELL_ID];
    if (!cell) cell = [[[MAZeroCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: MA_LISTS_CELL_ID] autorelease];
    
    if (indexPath.section == 1)
    {
        cell.textLabel.textColor = [MAController btTextColor];
        cell.textLabel.text = LSTR(@"L_New");
        cell.detailTextLabel.text = @"";
        return cell;
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    
    NSDictionary* l = [[MA_CONTROLLER lists] objectAtIndex: indexPath.row];
    cell.textLabel.text = [l objectForKey: LIST_NAME];
    
    NSString* s1 = nil;
    NUMBER_STR([[l objectForKey: LIST_TRACKS] intValue], @"L_Tr0", @"L_Tr1", @"L_Tr21", @"L_Tr2", s1);
    NSString* s = [[NSString alloc] initWithFormat: s1, [[l objectForKey: LIST_TRACKS] intValue]];
    cell.detailTextLabel.text = s;
    [s release];
    
    return cell;
}

//---------------------------------------------------------------------------------
// <UITableViewDelegate>
//---------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section) [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    if (indexPath.section == 1)
    {
        UIViewController* vc = [[MAAddController alloc] initWithStyle: UITableViewStyleGrouped];
        [self.navigationController pushViewController: vc animated: YES];
        [vc release];
    } else {
        NSDictionary* l = [[MA_CONTROLLER lists] objectAtIndex: indexPath.row];
        [MA_CONTROLLER setList: [[l objectForKey: LIST_ID] intValue]];
        [self onCancel];
    }
}

//---------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 2) ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

//---------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSDictionary* l = [[MA_CONTROLLER lists] objectAtIndex: indexPath.row];
        [MA_CONTROLLER deleteList: [[l objectForKey: LIST_ID] intValue]];
        [self.tableView reloadData];
    }
}


//---------------------------------------------------------------------------------
// UIControlEventEditingChanged
//---------------------------------------------------------------------------------
- (void)textFieldDidChange: (id)sender
{
    NSString* t = [_cellN input].text;
    if (![t isEqualToString: [[MA_CONTROLLER list] objectForKey: LIST_NAME]]) [MA_CONTROLLER editList: t];
}

@end
