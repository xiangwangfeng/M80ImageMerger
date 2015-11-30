//
//  M80ImageGenerator.h
//  M80Image
//
//  Created by amao on 11/18/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface M80ImageGenerator : NSObject
@property (nonatomic,strong)    NSError *error;

- (BOOL)feedImage:(UIImage *)image;
- (BOOL)feedImages:(NSArray *)images;

- (UIImage *)generate;
@end
