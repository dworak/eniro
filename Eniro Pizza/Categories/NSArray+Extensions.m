//
//  NSArray+Extensions.m
//  Eniro Pizza
//
//  Created by Lukasz Dworakowski on 30/11/14.
//  Copyright (c) 2014 Eniro AB. All rights reserved.
//

#import "NSArray+Extensions.h"

@implementation NSArray (Extensions)

- (id) _firstForKeyPath: (NSString*) keyPath
{
    NSArray* array = [self valueForKeyPath: keyPath];
    if ([array respondsToSelector: @selector(objectAtIndex:)] &&
       [array respondsToSelector: @selector(count)]) {
        if( [array count] )
            return [array objectAtIndex: 0];
        else
            return nil;
    }
    else {
        return nil;
    }
}

@end
