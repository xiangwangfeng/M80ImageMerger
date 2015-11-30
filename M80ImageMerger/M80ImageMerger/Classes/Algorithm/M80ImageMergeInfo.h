//
//  M80ImageMergeInfo.h
//  M80Image
//
//  Created by amao on 11/18/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface M80ImageMergeInfo : NSObject
@property (nonatomic,strong)    UIImage     *firstImage;
@property (nonatomic,strong)    UIImage     *secondImage;
@property (nonatomic,assign)    NSInteger   firstOffset;    //为计算方便,此处为从bottom计算的offset
@property (nonatomic,assign)    NSInteger   secondOffset;   //为计算方便,此处为从bottom计算的offset
@property (nonatomic,assign)    NSInteger   length;
@end


