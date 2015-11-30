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
    
    
    
    int **matrix = new int*[[firstLines count]];
    for (int i = 0; i < [firstLines count]; i++) {
        matrix[i] = new int[[secondLines count]];
    }
    
    
    
    long long firstValueInSecondLines = [[secondLines firstObject] longLongValue];
    for (NSInteger i = 0; i < [firstLines count]; i++)
    {
        long long value = [[firstLines objectAtIndex:i] longLongValue];
        matrix[i][0] = value == firstValueInSecondLines;
    }
    long long firstValueInFirstLines = [[firstLines firstObject] longLongValue];
    for (NSInteger  i = 0; i < [secondLines count]; i++)
    {
        long long value = [[secondLines objectAtIndex:i] longLongValue];
        matrix[0][i] = value == firstValueInFirstLines;
    }
    
    NSInteger length = 0,x = 0,y = 0;
    for (NSInteger i = 1 ; i < [firstLines count]; i ++)
    {
        for (NSInteger  j = 1; j < [secondLines count]; j++)
        {
            if ([[firstLines objectAtIndex:i] longLongValue] == [[secondLines objectAtIndex:j] longLongValue])
            {
                int value = matrix[i-1][j-1]+ 1;
                matrix[i][j] = value;
                if (value > length)
                {
                    length = value;
                    x = i;
                    y = j;
                }
                
            }
            else
            {
                matrix[i][j]= 0;
            }
        }
    }
    
    for (int i = 0; i < [firstLines count]; ++i)
        delete [] matrix[i];
    delete [] matrix;
    
    info.length = length;
    info.firstOffset = firstImage.size.height - (x - length + 1);
    info.secondOffset= secondImage.size.height - (y - length + 1);

    return info;
}
@end