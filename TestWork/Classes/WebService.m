//
//  WebService.m
//  TestWork
//
//  Created by Иван on 19/06/15.
//  Copyright (c) 2015 //  Created by Greg Bates on 07/19/15.
//  Copyright (c) 2015 Greg. All rights reserved.. All rights reserved.
//

#import "WebService.h"
#import "AFAppDotNetAPIClient.h"
#import "AppDelegate.h"



@implementation WebService



+ (void)makePostRequestWithMethod:(NSString *)method parameters:(NSDictionary *)jsonObject
      successBlock:(void (^)(NSDictionary *response))successBlock
        errorBlock:(void (^)(NSError *error))errorBlock
{    
    [[AFAppDotNetAPIClient sharedClient] POST:method
                                       parameters:jsonObject
                                          success:^(NSURLSessionDataTask * __unused task, id JSON)
     {

         
         if (successBlock) {
             successBlock(JSON);
         }
         
         
         DMLog(@"\n\n%@:\n%@",method, JSON);

         
     } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        // DMLog(@"%@",operation.str);

         DMLog(@"%@:\n%@",method, error);

         if (errorBlock) {
             errorBlock(error);
         }
         
     }];
    
}

+ (void)makeGetRequestWithMethod:(NSString *)method parameters:(NSDictionary *)jsonObject
                     successBlock:(void (^)(NSDictionary *response))successBlock
                       errorBlock:(void (^)(NSError *error))errorBlock
{
    
    
    [[AFAppDotNetAPIClient sharedClient] GET:method
                                       parameters:jsonObject
                                          success:^(NSURLSessionDataTask * __unused task, id JSON)
     {
         if (successBlock) {
             successBlock(JSON);
         }
         
      //   DMLog(@"%@:\n%@",method, JSON);
         
     } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
         
         if (errorBlock) {
             errorBlock(error);
             DMLog(@"%@:\n%@",method, error);
         }
     }];
    
}

+ (void)checkVersionWithSuccessBlock:(void (^)(NSDictionary *response))successBlock
                          errorBlock:(void (^)(NSError *error))errorBlock
{
    [[AFAppDotNetAPIClient sharedClient] POST:@"CheckVersion"
                                       parameters:nil
                                          success:^(NSURLSessionDataTask * __unused task, id JSON)
     {
         if (successBlock) {
             successBlock(JSON);
         }
         
         DMLog(@"%@", JSON);
         
     } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
         
         if (errorBlock) {
             errorBlock(error);
             DMLog(@"%@", error);
         }
     }];
}

@end