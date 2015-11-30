//
//  M80ImageFingerprint.h
//  M80Image
//
//  Created by amao on 11/18/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface M80ImageFingerprint : NSObject
@property (nonatomic,strong)    NSArray *lines;
+ (instancetype)fingerprint:(UIImage *)image;
@end
