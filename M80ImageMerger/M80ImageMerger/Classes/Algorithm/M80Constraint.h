//
//  M80Constraint.h
//  M80ImageMerger
//
//  Created by amao on 2017/12/29.
//  Copyright © 2017年 M80. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface M80Constraint : NSObject
@property (nonatomic,assign)    CGFloat minImageHeight;

- (NSInteger)topOffset;
- (NSInteger)bottomOffset;
- (NSInteger)requiredThreshold;
@end
