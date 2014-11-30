//
//  ViewController.m
//  Eniro Pizza
//
//  Created by Sebastian Buks on 28/07/14.
//  Copyright (c) 2014 Eniro AB. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "LDAdvertWS.h"

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray *fetchedAdverts;

@end

@implementation ViewController

@synthesize aTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.aTableView.delegate = self;
    self.aTableView.dataSource = self;
    self.aTableView.backgroundColor = [UIColor clearColor];
    
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark UITableViewDelegate -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self fetchedAdverts].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"PizzaCellItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    LDAdvertWS *advert = [[self fetchedAdverts] objectAtIndex:indexPath.row];
    cell.textLabel.text = advert.companyName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"id:%.f lat:%@ lon:%@", advert.eniroId.doubleValue, advert.latitude, advert.longitude];
        
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
   [cell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark Load Data -

- (void)loadData
{
    AFSecurityPolicy *policy = [[AFSecurityPolicy alloc] init];
    [policy setAllowInvalidCertificates:YES];
    
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    operationManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *latitude = @"59.37264";
    NSString *longitude = @"18.01658";
    NSString *key = @"6401495041230735255";
    NSString *profile = @"dworak";
    NSString *search_word = @"pizza";
    NSString *country = @"se";
    NSString *version = @"1.1.3";
    NSString *baseURL = @"http://api.eniro.com/cs/proximity/basic";

    NSString *requestString = [NSString stringWithFormat:@"%@?key=%@&profile=%@&search_word=%@&latitude=%@&longitude=%@&country=%@&version=%@",baseURL,key, profile,search_word,latitude,longitude,country,version];
    
    __weak typeof(self) weakSelf = self;
    [operationManager GET:requestString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *adverts = [responseObject valueForKey:@"adverts"];
        for (NSDictionary *advert in adverts)
        {
            NSError *error = nil;
            LDAdvertWS *advertWS = [[LDAdvertWS alloc] initWithDictionary:advert error:&error];
            
            if (error)
            {
                NSLog(@"[ERROR] occured: %@", error.localizedDescription);
            }
            else
            {
                [[weakSelf fetchedAdverts] addObject:advertWS];
            }
        }
        
        [[weakSelf fetchedAdverts] sortUsingComparator:^NSComparisonResult(LDAdvertWS *obj1, LDAdvertWS *obj2) {
            return [obj1.eniroId compare:obj2.eniroId];
        }];
        
        [[weakSelf aTableView] reloadData];
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[ERROR] occured: %@", error.localizedDescription);
    }];
}

#pragma mark Private - 

- (NSMutableArray *)fetchedAdverts
{
    if (!_fetchedAdverts)
    {
        _fetchedAdverts = [NSMutableArray new];
    }
    
    return _fetchedAdverts;
}

@end
