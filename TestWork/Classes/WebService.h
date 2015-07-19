//
//  WebService.h
//  TestWork
//
//  Created by Иван on 19/06/15.
//  Copyright (c) 2015 //  Created by Greg Bates on 07/19/15.
//  Copyright (c) 2015 Greg. All rights reserved.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebService : NSObject

+ (void)makePostRequestWithMethod:(NSString *)method parameters:(NSDictionary *)jsonObject
                     successBlock:(void (^)(NSDictionary *response))successBlock
                       errorBlock:(void (^)(NSError *error))errorBlock;

+ (void)makeGetRequestWithMethod:(NSString *)method parameters:(NSDictionary *)jsonObject
                    successBlock:(void (^)(NSDictionary *response))successBlock
                      errorBlock:(void (^)(NSError *error))errorBlock;
+ (void)checkVersionWithSuccessBlock:(void (^)(NSDictionary *response))successBlock
                          errorBlock:(void (^)(NSError *error))errorBlock;


@end