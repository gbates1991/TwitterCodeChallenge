//
//  FeedItemTemp.m
//  TestWork
//
//  Created by Иван on 19/06/15.
//  Copyright (c) 2015 //  Created by Greg Bates on 07/19/15.
//  Copyright (c) 2015 Greg. All rights reserved.. All rights reserved.
//

#import "FeedItemTemp.h"
#import "AppDelegate.h"

@implementation FeedItemTemp
@synthesize link, title, descriptionText, datePublish, imageUrl, feedId;
- (id)initWithJson:(NSDictionary *)resp
{
    self = [super init];
    if (self)
    {
        self.feedId = [resp objectForKey:@"id_str"];

        NSDictionary *userDict = [resp objectForKey:@"user"];
        if (userDict) {
            self.title = [userDict objectForKey:@"name"];
            self.imageUrl = [userDict objectForKey:@"profile_image_url"];
            self.link = [userDict objectForKey:@"profile_banner_url"]; // just any url from feed
        }
        self.descriptionText = [resp objectForKey:@"text"];
        self.datePublish = [ApplicationDelegate.dateFormatter dateFromString:[resp objectForKey:@"created_at"]];
    }
    
    return self;
}

@end
