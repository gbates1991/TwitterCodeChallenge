//
//  FeedItemOrigin.h
//  TestWork
//
//  Created by Иван on 19/06/15.
//  Copyright (c) 2015 //  Created by Greg Bates on 07/19/15.
//  Copyright (c) 2015 Greg. All rights reserved.. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FeedItemOrigin <NSObject>

@property (nonatomic, retain) NSString * feedId;
@property (nonatomic, retain) NSDate * datePublish;
@property (nonatomic, retain) NSString * descriptionText;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * title;

@end
