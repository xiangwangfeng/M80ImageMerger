//
//  M80ImageFingerprint.m
//  M80Image
//
//  Created by amao on 11/18/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "M80ImageFingerprint.h"
#import <zlib.h>
#import "UIImage+M80.h"


@interface M80ImageFingerprint ()
@property (nonatomic,assign)    M80FingerprintType  type;
@end



@implementation M80ImageFingerprint
+ (instancetype)fingerprint:(UIImage *)image
                       type:(M80FingerprintType)type;
{
    M80ImageFingerprint *instance = [[M80ImageFingerprint alloc] init];
    instance.type = type;
    [instance calc:image];
    return instance;
}

- (void)calc:(UIImage *)image
{
    UIImage *input = [[UIScreen mainScreen] scale] < 3 ? image : [image m80_gradientImage];
    if (_type == M80FingerprintTypeCRC)
    {
        [self calcCRCImage:input];
    }
    else if(_type == M80FingerprintTypeMin)
    {
        [self calcMinImage:input];
    }
}

- (void)calcCRCImage:(UIImage *)image
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

- (void)calcMinImage:(UIImage *)image
{
    NSMutableArray *array = [NSMutableArray array];
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    NSInteger height = image.size.height;
    NSInteger width = image.size.width;
    
    for (NSInteger y = 0; y < height; y++)
    {
        NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
        for (NSInteger x = 0; x < width; x++)
        {
            const UInt8 *pixel = &(data[y * width * 4 + x * 4]);
            int32_t gray = 0.3 * pixel[3] + 0.59 * pixel[2] + 0.11 * pixel[1];
            
            if (map[@(gray)] == nil)
            {
                map[@(gray)] = @(1);
            }
            else
            {
                map[@(gray)] = @([map[@(gray)] integerValue] + 1);
            }
        }
        NSMutableArray *numbers = [NSMutableArray array];
        for (NSNumber *key in map.allKeys)
        {
            NSValue *value = [NSValue valueWithRange:NSMakeRange([key integerValue], [map[key] integerValue])];
            [numbers addObject:value];
        }
        
        [numbers sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSInteger first = [obj1 rangeValue].length;
            NSInteger second = [obj2 rangeValue].length;
            return  first < second ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        NSInteger print = 255;
        NSInteger count = [numbers count] * 0.5;
        
        for (NSInteger i = 0; i < count; i++)
        {
            NSInteger value = [numbers[i] rangeValue].location;
            if (print > value)
            {
                print = value;
            }
        }
        [array addObject:@(print)];
    }
    _lines = array;
    CFRelease(pixelData);
}
@end
