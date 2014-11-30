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

#import <MapKit/MapKit.h>

@interface ViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) NSMutableArray *fetchedAdverts;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *lastLocation;

@end

@implementation ViewController

@synthesize aTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.aTableView.delegate = self;
    self.aTableView.dataSource = self;
    self.aTableView.backgroundColor = [UIColor clearColor];
    
    [self checkForGPS];
    [self turnOnLocationServices];
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
    
    NSString *latitude = [NSString stringWithFormat:@"%f",_lastLocation.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",_lastLocation.coordinate.longitude];
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

#pragma mark Location -

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (!self.lastLocation)
    {
        self.lastLocation = newLocation;
    }
    
    if (newLocation.coordinate.latitude != self.lastLocation.coordinate.latitude &&
        newLocation.coordinate.longitude != self.lastLocation.coordinate.longitude)
    {
        self.lastLocation = newLocation;
        NSLog(@"[LOG] New location: %f, %f",
              self.lastLocation.coordinate.latitude,
              self.lastLocation.coordinate.longitude);

        [self loadData];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // Handle error
}

#pragma mark Private - 

- (void)checkForGPS
{
    // If location services are disabled by user, show special information.
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
       NSLog(@"[ERROR] No access to GPS");
    }
}

- (void)turnOnLocationServices
{
    [[self locationManager] requestWhenInUseAuthorization];
    [[self locationManager] startUpdatingLocation];
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.distanceFilter = kCLDistanceFilterNone; //Whenever we move
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}

- (NSMutableArray *)fetchedAdverts
{
    if (!_fetchedAdverts)
    {
        _fetchedAdverts = [NSMutableArray new];
    }
    
    return _fetchedAdverts;
}

@end
