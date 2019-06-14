//
//  M80Constraint.h
//  M80ImageMerger
//
//  Created by amao on 2017/12/29.
//  Copyright © 2017年 M80. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "M80ImageFingerprint.h"
@class M80ImageMergeInfo;

@interface M80Constraint : NSObject
@property (nonatomic,assign)    CGFloat minImageHeight;

+ (NSInteger)topOffset;
+ (NSInteger)bottomOffset;
+ (BOOL)isInfoValid:(M80ImageMergeInfo *)info;
+ (BOOL)shouldUseGradientImage:(M80FingerprintType)type;
@end
