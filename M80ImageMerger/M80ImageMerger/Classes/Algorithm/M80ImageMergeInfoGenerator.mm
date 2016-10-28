//
//  M80ImageMergeInfoGenerator.m
//  M80ImageMerger
//
//  Created by amao on 11/27/15.
//  Copyright © 2015 M80. All rights reserved.
//

#import "M80ImageMergeInfoGenerator.h"
#import "M80ImageFingerprint.h"

@interface M80ImageMergeInfoGenerator ()

@end


@implementation M80ImageMergeInfoGenerator
- (instancetype)init
{
    if (self = [super init])
    {
    }
    return self;
}




- (M80ImageMergeInfo *)infoByImage:(UIImage *)firstImage
                       secondImage:(UIImage *)secondImage
{
    M80ImageMergeInfo *info = [[M80ImageMergeInfo alloc] init];
    info.firstImage = firstImage;
    info.secondImage = secondImage;
    
    
    M80ImageFingerprint *firstFingerprint = [M80ImageFingerprint fingerprint:firstImage];
    M80ImageFingerprint *secondFingerprint= [M80ImageFingerprint fingerprint:secondImage];
    
    NSArray *firstLines = [firstFingerprint lines];
    NSArray *secondLines= [secondFingerprint lines];
    
    NSInteger firstLinesCount = (NSInteger)[firstLines count];
    NSInteger secondLinesCount = (NSInteger)[secondLines count];
    
    int **matrix = new int*[2];
    for (int i = 0; i < 2; i++) {
        matrix[i] = new int[[secondLines count]];
    }
    
    for (NSInteger j = 0; j < secondLinesCount; j++)
    {
        matrix[0][j] = firstLines[0] == secondLines[j] ? 1 : 0;
    }
    
    NSInteger length = 0,x = 0,y = 0;
    
    for (NSInteger i = 1 ; i < firstLinesCount; i ++)
    {
        for (NSInteger  j = 0; j < secondLinesCount; j++)
        {
            if ([firstLines[i] longLongValue] == [secondLines[j] longLongValue])
            {
                int value = 0;
                if (j != 0)
                {
                    value = matrix[(i + 1) % 2][j-1] + 1;
                }
                matrix[i % 2][j] = value;
                
                if (value > length)
                {
                    length = value;
                    x = i;
                    y = j;
                }
            }
            else
            {
                matrix[i % 2][j] = 0;
            }
        }
    }
    
    for (int i = 0; i < 2; i++)
        delete [] matrix[i];
    delete [] matrix;
    
    info.length = length;
    info.firstOffset = firstImage.size.height - (x - length + 1);
    info.secondOffset= secondImage.size.height - (y - length + 1);
    
    return info;
}
@end
