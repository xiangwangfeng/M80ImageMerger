//
//  M80ImageFingerprint.m
//  M80Image
//
//  Created by amao on 11/18/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "M80ImageFingerprint.h"
#import <zlib.h>

@implementation M80ImageFingerprint
+ (instancetype)fingerprint:(UIImage *)image
{
    M80ImageFingerprint *instance = [[M80ImageFingerprint alloc] init];
    [instance cal:image];
    return instance;
}

- (void)cal:(UIImage *)image
{
    NSMutableArray *array = [NSMutableArray array];
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    NSInteger height = image.size.height;
    NSInteger width = image.size.width;
    
    for (NSInteger y = 0; y < height; y++)
    {
        NSData *cacheData = [NSData dataWithBytes:data + y * width * 4
                                           length:width * 4];
        uLong print = crc32(0, [cacheData bytes], (uInt)[cacheData length]);
        [array addObject:@(print)];
    }
    _lines = array;
    CFRelease(pixelData);
}
@end
