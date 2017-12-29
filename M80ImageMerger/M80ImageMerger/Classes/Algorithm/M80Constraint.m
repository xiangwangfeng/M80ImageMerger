//
//  M80Constraint.m
//  M80ImageMerger
//
//  Created by amao on 2017/12/29.
//  Copyright © 2017年 M80. All rights reserved.
//

#import "M80Constraint.h"


@implementation M80Constraint
- (NSInteger)topOffset
{
    if ([UIScreen mainScreen].bounds.size.height == 812)
    {
        return (44 + 44) * 3;
    }
    else
    {
        return (44 + 20) * [[UIScreen mainScreen] scale];
    }
}

- (NSInteger)bottomOffset
{
    if ([UIScreen mainScreen].bounds.size.height == 812)
    {
        return (44 + 34) * 3;
    }
    else
    {
        return (44) * [[UIScreen mainScreen] scale];
    }
}

- (NSInteger)requiredThreshold
{
    return (NSInteger)((self.minImageHeight - self.topOffset - self.bottomOffset) * 0.05);
}

@end
