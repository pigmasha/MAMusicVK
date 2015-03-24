//
//  MACells.h
//
//  Created by M on 17.11.14.
//  Copyright (c) 2014. All rights reserved.
//

// Cell with zero margins
@interface MAZeroCell : UITableViewCell
@end

//=================================================================================

@interface MAInputCell : MAZeroCell

- (UITextField*)input;

@end
