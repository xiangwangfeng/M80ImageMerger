//
//  M80ImageFingerprint.h
//  M80Image
//
//  Created by amao on 11/18/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    M80FingerprintTypeCRC,
    M80FingerprintTypeHistogram,  
} M80FingerprintType;



@interface M80ImageFingerprint : NSObject
@property (nonatomic,strong)    NSArray *lines;
+ (instancetype)fingerprint:(UIImage *)image
                       type:(M80FingerprintType)type;

@end
