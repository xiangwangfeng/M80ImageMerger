//
//  M80ImageViewController.h
//  M80ImageMerger
//
//  Created by amao on 11/27/15.
//  Copyright © 2015 M80. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface M80ImageViewController : UIViewController
@property (nonatomic,copy)  dispatch_block_t completion;
- (instancetype)initWithImage:(UIImage *)image;
@end
