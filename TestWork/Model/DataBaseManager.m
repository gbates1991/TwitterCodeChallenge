//
//  DataBaseManager.m
//  TestWork
//
//  Created by Иван on 19/07/15.
//  Copyright (c) 2015 //  Created by Greg Bates on 07/19/15.
//  Copyright (c) 2015 Greg. All rights reserved.. All rights reserved.
//

#import "DataBaseManager.h"
#import "FeedItem.h"
#import "FeedItemTemp.h"
#import <CoreData/CoreData.h>

@interface DataBaseManager ()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation DataBaseManager

+ (DataBaseManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static DataBaseManager *dataBaseManager = nil;
    
    dispatch_once(&onceToken, ^{
        dataBaseManager = [[DataBaseManager alloc] init];
    });
    return dataBaseManager;
}

-(void)saveNewItemWithTempItem:(FeedItemTemp *)itemTemp
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    FeedItem *feedItem;
    
    NSArray *allItems = [self findItemsById:itemTemp.feedId];

    if (allItems.count > 0) {
        feedItem = [allItems firstObject];
    }
    else
        feedItem = [NSEntityDescription insertNewObjectForEntityForName:@"FeedItem" inManagedObjectContext:context];
    
    feedItem.feedId = itemTemp.feedId;
    feedItem.title = itemTemp.title;
    feedItem.descriptionText = itemTemp.descriptionText;
    feedItem.link = itemTemp.link;
    feedItem.datePublish = itemTemp.datePublish;
    feedItem.imageUrl = itemTemp.imageUrl;

    [self saveContext];
}

-(void)deleteItem:(FeedItem *)feedItem
{
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:feedItem];
    [self saveContext];
}

-(NSArray *)findItemsById:(NSString *)feedID
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"FeedItem" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(feedId == %@)",feedID];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (objects == nil)
    {
        NSLog(@"%@",error);
    }
    return objects;
}

-(NSArray *)findAllItems
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"FeedItem" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (objects == nil)
    {
        NSLog(@"%@",error);
    }
    return objects;
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
