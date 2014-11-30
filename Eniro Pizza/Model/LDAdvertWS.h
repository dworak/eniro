//
//  LDAdvert.h
//  Eniro Pizza
//
//  Created by Lukasz Dworakowski on 30/11/14.
//  Copyright (c) 2014 Eniro AB. All rights reserved.
//

#import "JSONModel.h"

@interface LDAdvertWS : JSONModel

@property (strong, nonatomic) NSNumber *eniroId;
@property (strong, nonatomic) NSString *companyName;
@property (strong, nonatomic) NSDictionary *companyAddress;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) NSNumber *latitude;

@end
