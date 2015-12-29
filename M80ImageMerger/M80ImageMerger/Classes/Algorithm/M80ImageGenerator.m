//
//  M80ImageGenerator.m
//  M80Image
//
//  Created by amao on 11/18/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "M80ImageGenerator.h"
#import "M80ImageMergeInfoGenerator.h"
#import "UIImage+M80.h"

@interface M80ImageGenerator ()
@property (nonatomic,strong)    UIImage *firstImage;
@property (nonatomic,strong)    NSMutableArray *infos;
@end

@implementation M80ImageGenerator
- (instancetype)init
{
    if (self = [super init])
    {
        _infos = @[].mutableCopy;
    }
    return self;
}

- (BOOL)feedImages:(NSArray *)images
{
    for (UIImage *image in images)
    {
        @autoreleasepool
        {
            if (![self feedImage:image])
            {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)feedImage:(UIImage *)image
{
    if (_error)
    {
        return NO;
    }
    
    BOOL success = NO;
    if (image)
    {
        if (_firstImage == nil)
        {
            _firstImage = image;
            success = YES;
        }
        else
        {
            success = [self doFeedImage:image];
        }
    }
    return success;
}


- (BOOL)doFeedImage:(UIImage *)image
{
    UIImage *baseImage = [self baseImage];
    BOOL doFeed = image.size.width == baseImage.size.width &&
                  image.scale == baseImage.scale;
    if (doFeed)
    {
        M80ImageMergeInfoGenerator *generator =  [[M80ImageMergeInfoGenerator alloc] init];
        M80ImageMergeInfo *info = [generator infoByImage:baseImage
                                              secondImage:image];
        
        if (![self validInfo:info])
        {
            _error = [NSError errorWithDomain:@"www.xiangwangfeng.com"
                                         code:1
                                     userInfo:nil];
            doFeed = NO;
        }
        else
        {
            [_infos addObject:info];
        }
    }
    return doFeed;
}

- (BOOL)validInfo:(M80ImageMergeInfo *)info
{
    CGFloat ignoreOffset = 64 * 2; // 忽略navbar
    CGFloat thresholdPercentage = 0.1;
    CGFloat threshold = MIN(info.firstImage.size.height, info.secondImage.size.height) * thresholdPercentage;
    NSInteger firstOffset = info.firstImage.size.height - info.firstOffset;
    NSInteger length = info.length;
    return threshold > 0 &&
           length > (NSInteger)threshold &&
           firstOffset >= ignoreOffset;
}

- (UIImage *)generate
{
    if (_error || [_infos count] == 0)
    {
        return nil;
    }
    M80ImageMergeInfo *drawInfo = [_infos firstObject];
    [_infos removeObjectAtIndex:0];
    
    UIImage *result = nil;
    while (drawInfo)
    {
        @autoreleasepool
        {
            UIImage *firstImage = drawInfo.firstImage;
            UIImage *secondImage= drawInfo.secondImage;
            NSRange firstRange = NSMakeRange(firstImage.size.height - drawInfo.firstOffset, drawInfo.length);
            NSRange secondRange= NSMakeRange(secondImage.size.height - drawInfo.secondOffset, drawInfo.length);
            
            CGSize size = CGSizeMake(drawInfo.firstImage.size.width, firstRange.location + secondImage.size.height - secondRange.location);
            CGFloat scale = drawInfo.firstImage.scale;
            
            UIGraphicsBeginImageContextWithOptions(size, NO, scale);
            [firstImage drawInRect:CGRectMake(0, 0, firstImage.size.width, firstImage.size.height)];
            UIImage *subSecondImage = [secondImage m80_subImage:CGRectMake(0, secondRange.location, secondImage.size.width, secondImage.size.height - secondRange.location)];
            [subSecondImage drawInRect:CGRectMake(0, firstRange.location, size.width, subSecondImage.size.height)];
            result = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            drawInfo = nil;
            
            if ([_infos count])
            {
                M80ImageMergeInfo *info = [_infos firstObject];
                [_infos removeObjectAtIndex:0];
                info.firstImage = result;
                drawInfo = info;
            }

        }
    }
    return result;
}




- (UIImage *)baseImage
{
    UIImage *image  = nil;
    M80ImageMergeInfo *info = [_infos lastObject];
    if (info)
    {
        image = info.secondImage;
    }
    else
    {
        image = _firstImage;
    }
    return image;
}
@end
