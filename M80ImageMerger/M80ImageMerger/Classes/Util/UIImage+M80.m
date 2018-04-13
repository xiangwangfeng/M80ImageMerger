//
//  UIImage+M80.m
//  M80Image
//
//  Created by amao on 11/18/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "UIImage+M80.h"

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
@end
