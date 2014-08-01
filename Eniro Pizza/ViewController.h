//
//  ViewController.h
//  Eniro Pizza
//
//  Created by Sebastian Buks on 28/07/14.
//  Copyright (c) 2014 Eniro AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *aTableView;
}

@property (nonatomic, strong) UITableView *aTableView;

@end
