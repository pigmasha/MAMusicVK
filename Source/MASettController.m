//
//  MASettController.m
//  MAMusicVK
//
//  Created by M on 02.03.15.
//  Copyright (c) 2015. All rights reserved.
//

#import "MASettController.h"
#import "MACells.h"
#import "MAController.h"

@interface MASettController ()
{
    UISwitch* _useL;
    UISwitch* _sq;
    NSString* _date;
}
@end

//=================================================================================

@implementation MASettController

//---------------------------------------------------------------------------------
- (void)dealloc
{
    [_useL release];
    [_sq   release];
    [_date release];
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (void)loadView
{
    [super loadView];
    self.title = LSTR(@"S_Title");
    
    _useL = [[UISwitch alloc] initWithFrame: CGRectZero];
    _useL.on = SETT_BOOL_VAL(SETT_USE_LISTS);
    [_useL addTarget: self action: @selector(onUseL) forControlEvents: UIControlEventValueChanged];
    
    _sq = [[UISwitch alloc] initWithFrame: CGRectZero];
    _sq.on = SETT_BOOL_VAL(SETT_SQ);
    [_sq addTarget: self action: @selector(onSQ) forControlEvents: UIControlEventValueChanged];
    
    NSString* path = [[NSBundle mainBundle] executablePath];
    NSDate* d = [[[NSFileManager defaultManager] attributesOfItemAtPath: path error: nil] fileModificationDate];
    _date = [[NSDateFormatter localizedStringFromDate: d dateStyle: NSDateFormatterMediumStyle timeStyle: kCFDateFormatterShortStyle] retain];
    
    //if ([self.tableView respondsToSelector: @selector(setSeparatorInset:)]) self.tableView.separatorInset = UIEdgeInsetsZero;
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
- (void)onUseL
{
    SETT_SET_BOOL_VAL(SETT_USE_LISTS, _useL.on);
    [MA_CONTROLLER onSettUseL];
}

//---------------------------------------------------------------------------------
- (void)onSQ
{
    SETT_SET_BOOL_VAL(SETT_SQ, _sq.on);
}

//---------------------------------------------------------------------------------
// <UITableViewDataSource>
//---------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

//---------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0) ? 2 : 3;
}

//---------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? nil : LSTR(@"S_About");
}

//---------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return (section == 0) ? LSTR(@"S_SqB") : nil;
}


#define MA_SETT_CELL_ID @"S1"

//---------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: MA_SETT_CELL_ID];
    if (!cell)
    {
        cell = [[[MAZeroCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: MA_SETT_CELL_ID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0)
    {
        cell.accessoryView = (indexPath.row == 0) ? _useL : _sq;
        cell.textLabel.text = (indexPath.row == 0) ? LSTR(@"S_UseL") : LSTR(@"S_Sq");
        cell.detailTextLabel.text = @"";
        return cell;
    }
    
    cell.accessoryView = nil;
    switch (indexPath.row)
    {
        case 1:
            cell.textLabel.text = LSTR(@"S_Ver");
            cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleShortVersionString"];
            break;
        case 2:
            cell.textLabel.text = LSTR(@"S_Date");
            cell.detailTextLabel.text = _date;
            break;
        default:
            cell.textLabel.text = LSTR(@"S_Name");
            cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleDisplayName"];
            break;
    }
    
    return cell;
}

@end
