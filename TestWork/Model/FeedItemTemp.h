//
//  FeedItemTemp.h
//  TestWork
//
//  Created by Иван on 19/06/15.
//  Copyright (c) 2015 //  Created by Greg Bates on 07/19/15.
//  Copyright (c) 2015 Greg. All rights reserved.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedItemOrigin.h"

@interface FeedItemTemp : NSObject <FeedItemOrigin>

- (id)initWithJson:(NSDictionary *)resp;

@end
