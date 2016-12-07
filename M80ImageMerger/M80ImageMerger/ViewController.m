//
//  ViewController.m
//  M80ImageMerger
//
//  Created by amao on 11/27/15.
//  Copyright © 2015 M80. All rights reserved.
//

#import "ViewController.h"
#import "CTAssetsPickerController.h"
#import "M80ImageGenerator.h"
#import "SVProgressHUD.h"
#import "M80ImageViewController.h"
#import "UIView+Toast.h"
#import "M80RecentImageFinder.h"


@import Photos;

typedef void(^M80ImageMergeBlock)(UIImage *image,NSError *error);



@interface ViewController ()<CTAssetsPickerControllerDelegate,M80RecentImageFinderDelegate>
{
    dispatch_queue_t    _queue;
}
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (strong,nonatomic) M80RecentImageFinder *finder;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _queue = dispatch_queue_create("com.xiangwangfeng.image.queue", 0);
    
    _okButton.layer.cornerRadius = 5.0;
    _okButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _okButton.layer.borderWidth = 1;
    _okButton.layer.masksToBounds = YES;
    
    _finder = [[M80RecentImageFinder alloc] init];
    _finder.delegate = self;
    [_finder run];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (IBAction)onMergeBegin:(id)sender {
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusAuthorized) {
                CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
                picker.showsSelectionIndex = YES;
                picker.delegate = self;
                
                [self presentViewController:picker
                                   animated:YES
                                 completion:nil];
            }
            else {
                [self.view makeToast:NSLocalizedString(@"This app does not have access to your photos", nil)];
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
                                              [self showResult:image
                                                         error:error];
                                          }];
                                   
                               }];
}


- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker
{
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
}

#pragma mark - 合并图片
- (void)mergeImages:(NSArray *)assets
         completion:(M80ImageMergeBlock)completion
{
    if ([self validAssets:assets])
    {
        [SVProgressHUD show];
        dispatch_async(_queue, ^{
            
            M80ImageGenerator *generator = [self imageGeneratorBy:assets];
            UIImage *image = [generator generate];
            NSError *error = [generator error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [SVProgressHUD dismiss];

       
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


#pragma mark - 结果显示
- (void)showResult:(UIImage *)image
             error:(NSError *)error
{
    if (error)
    {
        NSInteger code = [error code];
        switch (code) {
            case M80MergeErrorNotSameWidth:
                [self showNotSameWidthTip];
                break;
            case M80MergeErrorNotEnoughOverlap:
                [self showNotEnoughOverlapError];
                break;
            default:
                assert(0);
                break;
        }
    }
    else
    {
        [self showImage:image];
    }
}

- (void)showNotSameWidthTip
{
    [self.view makeToast:NSLocalizedString(@"You should choose photos of same width", nil)];
}

- (void)showNotEnoughOverlapError
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Fail to stitch images", nil)
                                                                        message:NSLocalizedString(@"No enough overlap contents in these images", nil)
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [controller addAction:action];
    [self presentViewController:controller
                       animated:YES
                     completion:nil];
}

- (void)showImage:(UIImage *)image
{
    M80ImageViewController *vc = [[M80ImageViewController alloc] initWithImage:image];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}



#pragma mark - M80RecentImageFinderDelegate
- (void)onFindRecentImages:(NSArray *)images
{
    [self mergeImages:images
           completion:^(UIImage *image, NSError *error) {
               if (error == nil && image)
               {
                   [self showImage:image];
               }
           }];
}
@end
