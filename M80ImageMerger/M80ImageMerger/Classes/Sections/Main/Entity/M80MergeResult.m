//
//  M80MergeResult.m
//  M80ImageMerger
//
//  Created by amao on 2017/1/4.
//  Copyright © 2017年 M80. All rights reserved.
//

#import "M80MergeResult.h"
#import "UIView+Toast.h"

@import Photos;

@implementation M80MergeResult
+ (instancetype)resultBy:(UIImage *)image
                   error:(NSError *)error
                  assets:(NSArray *)assets
{
    M80MergeResult *result = [[M80MergeResult alloc] init];
    result.image = image;
    result.error = error;
    
    if (image && !error)
    {
        result.completion = ^(){
        
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest deleteAssets:assets];
            } completionHandler:nil];
            
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            [keyWindow makeToast:NSLocalizedString(@"Try to delete temporary image files", nil)];
        };
    }
    return result;
}
@end
