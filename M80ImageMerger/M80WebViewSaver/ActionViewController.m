//
//  ActionViewController.m
//  M80WebViewSaver
//
//  Created by amao on 2017/4/18.
//  Copyright © 2017年 M80. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SVProgressHUD.h"
#import "UIView+Toast.h"

typedef void(^M80FetchURLBlock)(NSURL *url);

@interface ActionViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (assign,nonatomic) BOOL inDrawing;
@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [SVProgressHUD show];
    [self fetchURL:^(NSURL *url) {
        
        if (url)
        {
            [self loadURL:url];
        }
        else
        {
            [SVProgressHUD dismiss];
            [self.view makeToast:@"获取页面信息失败"];
        }
    }];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - load url
- (void)fetchURL:(M80FetchURLBlock)block
{
    BOOL failed = YES;
    NSString *identifier = (NSString *)kUTTypeURL;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:identifier]) {
                failed = NO;
                [itemProvider loadItemForTypeIdentifier:identifier
                                                options:nil
                                      completionHandler:^(NSURL *url, NSError *error) {
                                          block(error ? nil : url);
                                      }];
                
                break;
            }
        }
    }
    if (failed)
    {
        block(nil);
    }
}

#pragma mark - WebView
- (void)setup
{
    [SVProgressHUD setViewForExtension:self.view];

    _webView.delegate = self;
    [_scrollView setHidden:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(done:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(save:)];
    
    
}

- (void)loadURL:(NSURL *)url
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [_webView loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
    self.inDrawing = YES;
    webView.frame = CGRectMake(0, 0, webView.scrollView.contentSize.width, webView.scrollView.contentSize.height);
    UIGraphicsBeginImageContextWithOptions(webView.scrollView.contentSize, NO, 0);
    [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.imageView.image = image;
    self.scrollView.contentSize = image.size;
    self.scrollView.hidden = NO;
    [self.view setNeedsLayout];
    self.inDrawing = NO;

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
    [self.view makeToast:@"获取页面信息失败"];
}

#pragma mark - layout
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect bounds = self.view.bounds;

    [self.contentView setFrame:bounds];
    [self.scrollView setFrame:bounds];
    
    if (!self.inDrawing) {
        [self.webView setFrame:bounds];
    }
    
    UIImage *image = self.imageView.image;
    self.imageView.frame = image? CGRectMake(0, 0, image.size.width, image.size.height) : CGRectZero;
}

#pragma mark -  event
- (IBAction)done:(id)sender {
    
     [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

- (IBAction)save:(id)sender {
    UIImage *image = self.imageView.image;
    if (image)
    {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        
    }
    else
    {
        [self.view makeToast:@"获取页面信息失败"];
    }
    
}

- (void)image:(UIImage *)image
didFinishSavingWithError:(NSError *) error
  contextInfo:(void *) contextInfo
{
    [self.view makeToast:error ? @"保存图片失败" : @"保存图片成功"];
}


@end
