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

@import Photos;

@interface ViewController ()<CTAssetsPickerControllerDelegate>
{
    dispatch_queue_t    _queue;
}
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _queue = dispatch_queue_create("com.xiangwangfeng.image.queue", 0);
    
    _okButton.layer.cornerRadius = 5.0;
    _okButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _okButton.layer.borderWidth = 1;
    _okButton.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (IBAction)onMergeBegin:(id)sender {
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusAuthorized) {
                CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
                picker.delegate = self;
                
                [self presentViewController:picker
                                   animated:YES
                                 completion:nil];
            }
            else {
                [self.view makeToast:@"请开启相册权限"];
            }
        });
    }];
}


- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   if ([self validAssets:assets])
                                   {
                                       [SVProgressHUD show];
                                       dispatch_async(_queue, ^{
                                           
                                           M80ImageGenerator *generator = [self imageGeneratorBy:assets];
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               
                                               [SVProgressHUD dismiss];
                                               [self showResult:generator];
                                           });
                                       });
                                   }
                                   else
                                   {
                                       [self.view makeToast:@"请选择相同宽度的图片"];
                                   }
                               }];
}


- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker
{
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
}


#pragma mark - misc
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

- (void)showResult:(M80ImageGenerator *)generator
{
    UIImage *image = [generator generate];
    if(image && ![generator error])
    {
        M80ImageViewController *vc = [[M80ImageViewController alloc] initWithImage:image];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav
                           animated:YES
                         completion:nil];
    }
    else
    {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"拼接失败"
                                                                            message:@"请选择有相同内容的图片进行拼接"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
        [controller addAction:action];
        [self presentViewController:controller
                           animated:YES
                         completion:nil];
    }
}
@end
