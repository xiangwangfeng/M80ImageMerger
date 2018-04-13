//
//  UIImage+M80.h
//  M80Image
//
//  Created by amao on 11/18/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (M80)
- (UIImage *)m80_subImage:(CGRect)rect;

- (UIImage *)m80_rangedImage:(NSRange)range;

- (BOOL)m80_saveAsPngFile:(NSString *)path;
@end
