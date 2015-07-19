//
//  DataBaseManager.h
//  TestWork
//
//  Created by Иван on 19/07/15.
//  Copyright (c) 2015 //  Created by Greg Bates on 07/19/15.
//  Copyright (c) 2015 Greg. All rights reserved.. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FeedItemTemp;
@class FeedItem;

@interface DataBaseManager : NSObject

+ (DataBaseManager *)sharedInstance;

-(void)saveNewItemWithTempItem:(FeedItemTemp *)itemTemp;
-(void)deleteItem:(FeedItem *)feedItem;
-(NSArray *)findAllItems;

@end
