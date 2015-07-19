//
//  ViewController.m
//  TestWork
//
//  Created by Иван on 19/06/15.
//  Copyright (c) 2015 //  Created by Greg Bates on 07/19/15.
//  Copyright (c) 2015 Greg. All rights reserved.. All rights reserved.
//

#import "ViewController.h"
#import "FeedItem.h"
#import "FeedItemTemp.h"
#import "CustomTableViewCell.h"
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import "NSString+CalculateHeight.h"
#import "UILabel+CalculateHeight.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "DataBaseManager.h"

@interface ViewController () <UIAlertViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *textFieldSearch;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) NSMutableArray *contentData;
@property (strong, nonatomic) NSMutableArray *contentDataFromServer;
@property (strong, nonatomic) NSMutableArray *contentDataFromDb;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (assign) NSInteger countdownInt;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topAligmentOfSearchBar;
@property (nonatomic,strong) ACAccountStore *accountStore;
@property (nonatomic,strong) NSURLConnection *connection;
@property (nonatomic,strong) NSMutableData *buffer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Twitter Feed";
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
}

-(void)refreshTable
{
    [self refreshTableForNewFeed:YES];
}

-(void)refreshTableForNewFeed:(BOOL)newFeed
{
    CGFloat height = 0;
    _textFieldSearch.hidden = YES;
    _contentData = [NSMutableArray array];
    [self.tableView reloadData];
    if(_segmentControl.selectedSegmentIndex == 0)
    {
        height = -40;
        _textFieldSearch.hidden = NO;

        if (newFeed) {
            [self fetchFeedWithText:_textFieldSearch.text];
        }else
        {
            _contentData = [NSMutableArray arrayWithArray:_contentDataFromServer];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                          withRowAnimation:UITableViewRowAnimationFade];
        }
    }else
    {
        NSArray *allFavoriteItems = [[DataBaseManager sharedInstance]findAllItems];
        _contentData = [NSMutableArray arrayWithArray:allFavoriteItems];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                      withRowAnimation:UITableViewRowAnimationFade];
        [self.refreshControl endRefreshing];

    }
    
    _topAligmentOfSearchBar.constant = height;
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        if (finished) {
        }
        
    }];
}

- (ACAccountStore *)accountStore
{
    if (_accountStore == nil)
    {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
}

-(void)fetchFeedWithText:(NSString *)searchText
{
    if (searchText.length == 0) {
        return;
    }
    @synchronized(self)
    {
        ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [self.accountStore requestAccessToAccountsWithType:accountType
                                                   options:NULL
                                                completion:^(BOOL granted, NSError *error)
         {
             if (granted)
             {
                 NSArray *accounts = [self.accountStore accountsWithAccountType:accountType];

                 if (accounts.count == 0) {
                     UIAlertView * alertError = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alertError show];
                 }else
                 {
                     NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
                     NSDictionary *parameters = @{@"count" : @"100",
                                                  @"q" : searchText};
                     
                     SLRequest *slRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                               requestMethod:SLRequestMethodGET
                                                                         URL:url
                                                                  parameters:parameters];
                     
                     slRequest.account = [accounts lastObject];
                     NSURLRequest *request = [slRequest preparedURLRequest];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                         ApplicationDelegate.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                     });
                 }

             }
             else
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             }
         }];
    }
}

-(void)deleteItem:(FeedItem *)feedItem
{
    if (feedItem)
    {
        [[DataBaseManager sharedInstance]deleteItem:feedItem];
    }
}

- (IBAction)pressedSegmentControl:(id)sender
{
    [self refreshTableForNewFeed:NO];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_contentData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedItemTemp *feedItem = [_contentData objectAtIndex:indexPath.row];
    
    NSString *titleStr = [NSString stringWithFormat:@"%@\n%@", feedItem.title, feedItem.descriptionText];
;
    CGFloat height = [titleStr getHeightOfFont:[UIFont systemFontOfSize:17] widht:self.tableView.frame.size.width - 100];
    if (height < 52) {
        height = 58;
    }
    return height + 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"TableCell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if( cell == nil ) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    //FeedItemTemp *feedItem
    id <FeedItemOrigin> feedItem = [_contentData objectAtIndex:indexPath.row];
    
    cell.labelDate.text = [ApplicationDelegate.dateFormatterUser stringFromDate:feedItem.datePublish];
    
    cell.labelDescription.font = [UIFont systemFontOfSize:17];
    cell.labelDescription.text = [NSString stringWithFormat:@"%@\n%@", feedItem.title, feedItem.descriptionText];
    
    cell.activity.hidden = NO;
    [cell.activity startAnimating];

    cell.imageThumb.image = nil;
    __weak UIImageView *weakThumb = cell.imageThumb;
    __weak UIActivityIndicatorView *weakActivity = cell.activity;

    [cell.imageThumb setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:feedItem.imageUrl]] placeholderImage:nil success:^(NSURLRequest *request,   NSHTTPURLResponse *response, UIImage *image) {
        if (weakThumb)
        {
            weakThumb.image = image;
            weakActivity.hidden = YES;
            [weakActivity stopAnimating];
        }
        if (weakActivity)
        {
            weakActivity.hidden = YES;
            [weakActivity stopAnimating];
        }

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Error: %@", error);
        if (weakActivity)
        {
            weakActivity.hidden = YES;
            [weakActivity stopAnimating];
        }
    }];
    
    [cell.buttonSave addTarget:self action:@selector(pressedSaveButton:) forControlEvents:UIControlEventTouchUpInside];
    cell.buttonSave.tag = indexPath.row;
    
    if(_segmentControl.selectedSegmentIndex == 0)
        cell.buttonSave.hidden = NO;
    else
        cell.buttonSave.hidden = YES;
  
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedItemTemp *feedItem = [_contentData objectAtIndex:indexPath.row];
    NSURL *linkUrl = [NSURL URLWithString:feedItem.link];
    
    if ([[UIApplication sharedApplication] canOpenURL:linkUrl]) {
        [[UIApplication sharedApplication] openURL:linkUrl];
    }
}

-(void)pressedSaveButton:(UIButton *)sender
{
    id <FeedItemOrigin> feedItem = [_contentData objectAtIndex:sender.tag];
    [[DataBaseManager sharedInstance]saveNewItemWithTempItem:feedItem];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_segmentControl.selectedSegmentIndex == 1)
        return YES;
    else
        return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FeedItem *feedItem = [_contentData objectAtIndex:indexPath.row];
        [self deleteItem:feedItem];
        [_contentData removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
        //add code here for when you hit delete
    }
}

#pragma mark - AlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            [self fetchFeedWithText:_textFieldSearch.text];
        }
    }
}

#pragma mark - TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _textFieldSearch) {
        [textField resignFirstResponder];
        [self fetchFeedWithText:_textFieldSearch.text];
        return NO;
    }
    return YES;
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.buffer = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [self.buffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.connection = nil;
    
    NSError *jsonParsingError = nil;
    NSDictionary *jsonResults = [NSJSONSerialization JSONObjectWithData:self.buffer options:0 error:&jsonParsingError];
    
    _contentData = [NSMutableArray array];
    
    NSArray *results = jsonResults[@"statuses"];
    if ([results count] == 0)
    {
        NSArray *errors = jsonResults[@"errors"];
        if ([errors count])
        {
            NSMutableArray *errorStrings = [NSMutableArray array];
            for (NSDictionary *errorDict in errors) {
                [errorStrings addObject:[errorDict objectForKey:@"message"]];
            }
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[errorStrings componentsJoinedByString:@",\n"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Search state not found" delegate:nil cancelButtonTitle:@"" otherButtonTitles:@"Ok", nil];
            [alert show];
        }
    }else
    {
        for (NSDictionary *tweet in results) {
            FeedItemTemp *feedItem = [[FeedItemTemp alloc]initWithJson:tweet];
            
            [_contentData addObject:feedItem];
        }
    }
    _contentDataFromServer = [NSMutableArray arrayWithArray:_contentData];
    self.buffer = nil;
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
    [self.tableView flashScrollIndicators];
    [ApplicationDelegate.HUD hide:YES];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [ApplicationDelegate.HUD hide:YES];
    self.connection = nil;
    self.buffer = nil;
    [self.refreshControl endRefreshing];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Try again" otherButtonTitles:@"Dismiss", nil];
    alert.tag = 1;
    [alert show];
    
    [self.tableView reloadData];
}

@end
