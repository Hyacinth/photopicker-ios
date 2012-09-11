//
//  ALAssetsLibrary+GCImagePickerControllerAdditions.m
//  QuickShot
//
//  Created by Caleb Davenport on 3/9/12.
//  Copyright (c) 2012 GUI Cocoa, LLC. All rights reserved.
//

#import "ALAssetsLibrary+GCImagePickerControllerAdditions.h"

@implementation ALAssetsLibrary (GCImagePickerControllerAdditions)

- (void)gcip_assetsGroupsWithTypes:(ALAssetsGroupType)types
                      assetsFilter:(ALAssetsFilter *)filter
                        completion:(void (^) (NSArray *groups))completion
                           failure:(void (^) (NSError *error))failure {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [self
     enumerateGroupsWithTypes:types
     usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
         if (group) {
             [group setAssetsFilter:filter];
             if ([group numberOfAssets] > 0) {
                 NSNumber *type = [group valueForProperty:ALAssetsGroupPropertyType];
                 NSMutableArray *groups = [dictionary objectForKey:type];
                 if (groups == nil) {
                     groups = [NSMutableArray arrayWithCapacity:1];
                     [dictionary setObject:groups forKey:type];
                 }
                 [groups addObject:group];
             }
         }
         else {
             
             // declare types
             static dispatch_once_t token;
             static NSArray *types = nil;
             dispatch_once(&token, ^{
                 types = @[
                     @(ALAssetsGroupSavedPhotos),
                     @(ALAssetsGroupPhotoStream),
                     @(ALAssetsGroupLibrary),
                     @(ALAssetsGroupAlbum),
                     @(ALAssetsGroupEvent),
                     @(ALAssetsGroupFaces)
                 ];
             });
             
             // sort known groups into final container
             NSMutableArray *array = [NSMutableArray array];
             for (NSNumber *typeNumber in types) {
                 NSMutableArray *groups = [dictionary objectForKey:typeNumber];
                 ALAssetsGroupType type = [typeNumber unsignedIntegerValue];
                 if (type != ALAssetsGroupEvent) {
                     [groups sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                         NSString *name1 = [obj1 valueForProperty:ALAssetsGroupPropertyName];
                         NSString *name2 = [obj2 valueForProperty:ALAssetsGroupPropertyName];
                         return [name1 localizedCompare:name2];
                     }];
                 }
                 [array addObjectsFromArray:groups];
                 [dictionary removeObjectForKey:typeNumber];
             }
             
             // call completion
             if (completion) {
                 dispatch_async(dispatch_get_main_queue(), ^{ completion([array copy]); });
             }
             
         }
     }
     failureBlock:^(NSError *error) {
         if (failure) {
             dispatch_async(dispatch_get_main_queue(), ^{ failure(error); });
         }
     }];
}

- (void)gcip_assetsInGroupGroupWithIdentifier:(NSString *)identifier
                                 assetsFilter:(ALAssetsFilter *)filter
                                   completion:(void (^) (ALAssetsGroup *group, NSArray *assets))completion
                                      failure:(void (^) (NSError *error))failure {
    [self
     enumerateGroupsWithTypes:ALAssetsGroupAll
     usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
         if (group) {
             NSString *groupIdentifier = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
             if ([groupIdentifier isEqualToString:identifier]) {
                 [group setAssetsFilter:filter];
                 NSMutableArray *assets = [NSMutableArray arrayWithCapacity:[group numberOfAssets]];
                 [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                     if (result) { [assets addObject:result]; }
                 }];
                 if (completion) {
                     dispatch_async(dispatch_get_main_queue(), ^{ completion(group, assets); });
                 }
                 *stop = YES;
             }
         }
     }
     failureBlock:^(NSError *error) {
         if (failure) {
             dispatch_async(dispatch_get_main_queue(), ^{ failure(error); });
         }
     }];
}

@end