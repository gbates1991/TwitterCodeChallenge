//
//  CustomTableViewCell.h
//  TestWork
//
//  Created by Иван on 19/06/15.
//  Copyright (c) 2015 //  Created by Greg Bates on 07/19/15.
//  Copyright (c) 2015 Greg. All rights reserved.. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageThumb;
@property (strong, nonatomic) IBOutlet UIButton *buttonSave;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *labelDescHeight;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
