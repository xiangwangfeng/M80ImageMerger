//
//  M80ImageMergeInfoGenerator.h
//  M80ImageMerger
//
//  Created by amao on 11/27/15.
//  Copyright © 2015 M80. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M80ImageMergeInfo.h"

@interface M80ImageMergeInfoGenerator : NSObject
- (M80ImageMergeInfo *)infoByImage:(UIImage *)firstImage
                       secondImage:(UIImage *)secondImage;

@end