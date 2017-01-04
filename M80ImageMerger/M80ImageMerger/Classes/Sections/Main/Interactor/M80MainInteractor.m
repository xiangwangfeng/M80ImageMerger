//
//  M80MainInteractor.m
//  M80ImageMerger
//
//  Created by amao on 2016/12/8.
//  Copyright © 2016年 M80. All rights reserved.
//

#import "M80MainInteractor.h"
#import "M80RecentImageFinder.h"
#import "CTAssetsPickerController.h"
#import "M80ImageGenerator.h"

@import Photos;


typedef void(^M80ImageMergeBlock)(UIImage *image,NSError *error);


@interface M80MainInteractor ()<M80RecentImageFinderDelegate,CTAssetsPickerControllerDelegate>
@property (nonatomic,strong) dispatch_queue_t queue;
@property (nonatomic,strong) M80RecentImageFinder *finder;
@end

@implementation M80MainInteractor

- (instancetype)init
{
    if (self = [super init])
    {
        _queue = dispatch_queue_create("com.xiangwangfeng.image.queue", 0);
        _finder = [[M80RecentImageFinder alloc] init];
        _finder.delegate = self;
    }
    return self;
}

- (void)run
{
    [_finder run];
}
#pragma mark - User case: choose iamges
- (void)chooseImages
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusAuthorized) {
                CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
                picker.showsSelectionIndex = YES;
                picker.delegate = self;
                
                [self.delegate presentViewController:picker
                                            animated:YES
                                          completion:nil];
            }
            else {
                [self.delegate photosRequestAuthorizationFailed];
            }
        });
    }];
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   
                                   [self mergeImages:assets
                                          completion:^(UIImage *image, NSError *error) {
                                              
                                              M80MergeResult *result = [M80MergeResult resultBy:image
                                                                                          error:error
                                                                                         assets:assets];
                                              [self.delegate showResult:result];
                                          }];
                                   
                               }];
}


- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker
{
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
}


#pragma mark - User case: merge images
- (void)mergeImages:(NSArray *)assets
         completion:(M80ImageMergeBlock)completion
{
    if ([self validAssets:assets])
    {
        [self.delegate mergeBegin];
        
        dispatch_async(_queue, ^{
            
            M80ImageGenerator *generator = [self imageGeneratorBy:assets];
            UIImage *image = [generator generate];
            NSError *error = [generator error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.delegate mergeEnd];
                
                if (completion) {
                    completion(image,error);
                }
                
            });
        });
    }
    else
    {
        if (completion) {
            completion(nil,[NSError errorWithDomain:M80ERRORDOMAIN
                                               code:M80MergeErrorNotSameWidth
                                           userInfo:Nil]);
        }
    }
}


- (M80ImageGenerator *)imageGeneratorBy:(NSArray *)assets
{
    M80ImageGenerator *generator = [[M80ImageGenerator alloc] init];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    
    for (PHAsset *asset in assets)
    {
        [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                          options:options
                                                    resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                                        UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                        [generator feedImage:image];
                                                    }];
    }
    return generator;
}

- (BOOL)validAssets:(NSArray *)assets
{
    BOOL valid = [assets count] > 1;
    NSUInteger pixelWidth = 0;
    if (valid)
    {
        for (PHAsset *asset in assets)
        {
            if ([asset mediaType] != PHAssetMediaTypeImage)
            {
                valid = NO;
                break;
            }
            if ([asset pixelWidth] != pixelWidth)
            {
                if (pixelWidth == 0)
                {
                    pixelWidth = [asset pixelWidth];
                }
                else
                {
                    valid = NO;
                    break;
                }
            }
            
        }
    }
    return valid;
}

#pragma mark - M80RecentImageFinderDelegate
- (void)onFindRecentImages:(NSArray *)images
{
    [self mergeImages:images
           completion:^(UIImage *image, NSError *error) {
               if (error == nil && image)
               {
                   M80MergeResult *result = [M80MergeResult resultBy:image
                                                               error:error
                                                              assets:images];
                   [self.delegate showResult:result];
               }
           }];
}
@end
