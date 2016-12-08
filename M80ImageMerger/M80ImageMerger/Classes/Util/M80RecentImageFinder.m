//
//  M80RecentImageFinder.m
//  M80ImageMerger
//
//  Created by amao on 2016/12/7.
//  Copyright © 2016年 M80. All rights reserved.
//

#import "M80RecentImageFinder.h"
@import Photos;

#define M80LASTSEARCHDATE   @"last_search_date_key"


@interface M80RecentImageFinder ()
@property (nonatomic,strong)    NSDate *lastSearchDate;  //防止每次启动就检查一遍
@end

@implementation M80RecentImageFinder
- (instancetype)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)run
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusAuthorized) {
                
                PHFetchResult *recentCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                                            subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded
                                                                                            options:nil];
                
                PHFetchOptions *fetchOptions = [PHFetchOptions new];
                fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
                fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
                
                PHAssetCollection *collection = [recentCollections firstObject];
                PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
                
                NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-120];
                NSDate *lastSearchDate = self.lastSearchDate;
                
                NSMutableArray *items = [NSMutableArray array];
                
                [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[PHAsset class]])
                    {
                        PHAsset *asset = (PHAsset *)obj;
                        NSDate *creationDate = asset.creationDate;
                        if ([creationDate timeIntervalSinceDate:date] > 0 &&
                            [creationDate timeIntervalSinceDate:lastSearchDate] > 0)
                        {
                            [items addObject:asset];
                        }
                    }
                }];
                
                if ([items count] > 1)
                {
                    [self.delegate onFindRecentImages:items];
                }
                
                self.lastSearchDate = [NSDate date];
            }
        });
    }];
}

- (void)onActive:(NSNotification *)notification
{
    [self run];
}

#pragma mark - lastSearchDate
- (NSDate *)lastSearchDate
{
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:M80LASTSEARCHDATE];
    return date ?: [NSDate dateWithTimeIntervalSince1970:0];
}

- (void)setLastSearchDate:(NSDate *)lastSearchDate
{
    [[NSUserDefaults standardUserDefaults] setObject:lastSearchDate
                                              forKey:M80LASTSEARCHDATE];
}
@end
