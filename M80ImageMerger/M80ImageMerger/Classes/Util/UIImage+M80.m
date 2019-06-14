//
//  UIImage+M80.m
//  M80Image
//
//  Created by amao on 11/18/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "UIImage+M80.h"

void M80ProviderReleaseData (void *info, const void *data, size_t size)
{
    free((void*)data);
}

uint8_t M80RGB(int8_t value)
{
#define M80_INDEX_LEN 7
    static uint8_t indexs[M80_INDEX_LEN] = {4,8,16,32,64,128,255};
    for (int i = 0; i< M80_INDEX_LEN; i++)
    {
        if (value <= indexs[i])
        {
            return indexs[i];
        }
    }
    return 255;
}

@implementation UIImage (M80)
- (UIImage *)m80_subImage:(CGRect)rect
{
    if (self.scale > 1.0f)
    {
        rect = CGRectMake(rect.origin.x * self.scale,
                          rect.origin.y * self.scale,
                          rect.size.width * self.scale,
                          rect.size.height * self.scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:self.scale
                                    orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

- (UIImage *)m80_rangedImage:(NSRange)range
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    
    CGRect imageRect = CGRectMake(0, 0, self.size.width * self.scale,self.size.height * self.scale);
    [self drawInRect:imageRect];
    
    CGFloat startY = (self.size.height - range.location) * self.scale;
    CGFloat endY   = (self.size.height - range.location + range.length) * self.scale;
    CGFloat width  = imageRect.size.width;
    
    {
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path moveToPoint:CGPointMake(0,startY)];
        [path addLineToPoint:CGPointMake(width, startY)];
        [[UIColor redColor] setStroke];
        [path stroke];
    }
    
    {
        
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path moveToPoint:CGPointMake(0,endY)];
        [path addLineToPoint:CGPointMake(width, endY)];
        [[UIColor redColor] setStroke];
        [path stroke];
    }
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
    
}

- (BOOL)m80_saveAsPngFile:(NSString *)path
{
    NSData *data = UIImagePNGRepresentation(self);
    return data && [data writeToFile:path
                          atomically:YES];
    
}


- (UIImage *)m80_gradientImage
{
    const int imageWidth = self.size.width;
    const int imageHeight = self.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t*rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
    
    int pixelNum = imageWidth * imageHeight;
    uint32_t*curPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, curPtr++)
    {
        uint8_t* ptr = (uint8_t*)curPtr;
        ptr[3] = M80RGB(ptr[3]);
        ptr[2] = M80RGB(ptr[2]);
        ptr[1] = M80RGB(ptr[1]);
    }
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, M80ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage*result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return result;
}



@end
