//
//  M80ImageViewController.m
//  M80ImageMerger
//
//  Created by amao on 11/27/15.
//  Copyright © 2015 M80. All rights reserved.
//

#import "M80ImageViewController.h"
#import "UIView+Toast.h"

@interface M80ImageViewController ()
@property (nonatomic,strong)    UIScrollView    *scrollView;
@property (nonatomic,strong)    UIImageView     *imageView;
@property (nonatomic,strong)    UIImage         *image;
@property (nonatomic,assign)    CGSize          contentSize;
@end

@implementation M80ImageViewController

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init])
    {
        _image = image;
        
        CGFloat scale = [[UIScreen mainScreen] scale];
        _contentSize = CGSizeMake(_image.size.width * _image.scale / scale, _image.size.height * _image.scale / scale);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    _scrollView.contentSize = _contentSize;
    [self.view addSubview:_scrollView];
    
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_scrollView addSubview:_imageView];
    
    _imageView.image = _image;
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(onDismiss:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil)
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(onSave:)];
    self.title = NSLocalizedString(@"Preview", nil);
}



- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    CGFloat x = (self.view.bounds.size.width - _contentSize.width ) / 2;
    CGRect frame = CGRectMake(x, 0, _contentSize.width,_contentSize.height);
    [_imageView setFrame:frame];
}


- (void)onDismiss:(id)sender
{
    dispatch_block_t completion = self.completion;
    [self dismissViewControllerAnimated:YES
                             completion:completion];
}

- (void)onSave:(id)sender
{
    UIImageWriteToSavedPhotosAlbum(_image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image:(UIImage *)image
didFinishSavingWithError:(NSError *) error
  contextInfo:(void *) contextInfo
{
    [self.view makeToast:error ? NSLocalizedString(@"Fail to save image", nil) : NSLocalizedString(@"Image saved successfully", nil)];
}
@end


