//
//  M80ImageMergeInfo.m
//  M80Image
//
//  Created by amao on 11/18/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "M80ImageMergeInfo.h"
#import "M80ImageFingerprint.h"

typedef struct
{
    NSInteger value;
    NSInteger threshold;
}InterestPoint;


@implementation M80ImageMergeInfo

+ (instancetype)infoBy:(UIImage *)firstImage
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
    
    //允许有大约 1% 的错误
    NSInteger threshold = MAX((NSInteger)(0.01 * MIN(firstImage.size.height, secondImage.size.height)),5);
    
    
    //初始化动态规划所需要的数组
    InterestPoint **matrix = (InterestPoint **)malloc(sizeof(InterestPoint *) * 2);
    for (NSInteger i = 0; i < 2; i++)
    {
        matrix[i] = (InterestPoint *)malloc(sizeof(InterestPoint) * (size_t)secondLinesCount);
    }
    for (NSInteger j = 0; j < secondLinesCount; j++)
    {
        InterestPoint point;
        point.value = firstLines[0] == secondLines[j] ? 1 : 0;
        point.threshold = threshold;
        matrix[0][j] = point;
    }
    
    
    //遍历并合并
    NSInteger length = 0,x = 0,y = 0;
    for (NSInteger i = 1 ; i < firstLinesCount; i ++)
    {
        for (NSInteger  j = 0; j < secondLinesCount; j++)
        {
            InterestPoint point;
            if ([firstLines[i] longLongValue] == [secondLines[j] longLongValue])
            {
                if (j == 0)
                {
                    point.value = 1;
                    point.threshold = threshold;
                    
                }
                else
                {
                    InterestPoint oldPoint = matrix[(i + 1) % 2][j-1];
                    point.value = oldPoint.value + 1;
                    point.threshold = MAX(threshold, oldPoint.threshold + 1);
                }
                if (point.value > length)
                {
                    length = point.value;
                    x = i;
                    y = j;
                }
            }
            else
            {
                if (j == 0)
                {
                    point.value = 0;
                    point.threshold = threshold;
                }
                else
                {
                    InterestPoint oldPoint = matrix[(i + 1) % 2][j-1];
                    point.value = oldPoint.threshold > 0 ? oldPoint.value + 1 : 0;
                    point.threshold = MAX(oldPoint.threshold - 1, 0);
                }
            }
            matrix[i % 2][j] = point;
        }
    }
    
    //清理
    for (NSInteger i = 0; i < 2; i++)
        free(matrix[i]);
    free(matrix);
    
    
    //更新数据
    info.length = length;
    info.firstOffset = firstImage.size.height - (x - length + 1);
    info.secondOffset= secondImage.size.height - (y - length + 1);
        
    return info;
}

@end


