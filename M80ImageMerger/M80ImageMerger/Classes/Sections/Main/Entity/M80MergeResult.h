//
//  M80MergeResult.h
//  M80ImageMerger
//
//  Created by amao on 2017/1/4.
//  Copyright © 2017年 M80. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface M80MergeResult : NSObject
@property (nonatomic,strong)    UIImage             *image;
@property (nonatomic,copy)      dispatch_block_t    completion;
@property (nonatomic,strong)    NSError             *error;

+ (instancetype)resultBy:(UIImage *)image
                   error:(NSError *)error
                  assets:(NSArray *)assets;
@end
