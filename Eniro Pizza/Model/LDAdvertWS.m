//
//  LDAdvert.m
//  Eniro Pizza
//
//  Created by Lukasz Dworakowski on 30/11/14.
//  Copyright (c) 2014 Eniro AB. All rights reserved.
//

#import "LDAdvertWS.h"

@implementation LDAdvertWS

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"location.coordinates.@first.longitude": @"longitude",
                                                       @"location.coordinates.@first.latitude" : @"latitude",
                                                       @"companyInfo.companyName" : @"companyName",
                                                       @"address" : @"companyAddress"
                                                       }];
}

@end
