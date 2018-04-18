//
//  M80Constraint.m
//  M80ImageMerger
//
//  Created by amao on 2017/12/29.
//  Copyright © 2017年 M80. All rights reserved.
//

#import "M80Constraint.h"
#import "M80ImageMergeInfo.h"


@implementation M80Constraint
+ (NSInteger)topOffset
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

+ (NSInteger)bottomOffset
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

+ (BOOL)isInfoValid:(M80ImageMergeInfo *)info
{
    NSInteger threshold = [M80Constraint requiredThreshold:info];
    NSInteger length = info.length;
    NSLog(@"validate info [%@] threshold %zd",info,threshold);
    return threshold > 0 &&
    length > threshold &&
    info.secondOffset > info.firstOffset;
}


+ (NSInteger)requiredThreshold:(M80ImageMergeInfo *)info
{
    NSInteger minImageHeight = MIN(info.firstImage.size.height, info.secondImage.size.height);
    double factor = [M80Constraint shouldUseGradientImage:info.type] ? 0.10618 : 0.0618;
    return (NSInteger)((minImageHeight - [M80Constraint topOffset] - [M80Constraint bottomOffset]) * factor);
    
}

+ (BOOL)shouldUseGradientImage:(M80FingerprintType)type
{
    return type == M80FingerprintTypeCRC && [[UIScreen mainScreen] scale] >= 3.0;
}
@end
