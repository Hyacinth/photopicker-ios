/*
 
 Copyright (C) 2011 GUI Cocoa, LLC.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "GCIPGroupPickerController.h"
#import "GCIPAssetPickerController.h"
#import "GCImagePickerController.h"

#import "ALAssetsLibrary+GCImagePickerControllerAdditions.h"

@implementation GCIPGroupPickerController {
    NSNumberFormatter *_numberFormatter;
}

#pragma mark - object methods

- (id)init {
    self = [super init];
    if (self) {
        self.title = [GCImagePickerController localizedString:@"PHOTO_LIBRARY"];
        self.showDisclosureIndicators = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(done)];
    }
    return self;
}

- (void)reloadAssets {
    if ([self isViewLoaded]) {
//        ALAssetsLibrary *library = [self.parentViewController performSelector:@selector(assetsLibrary)];
//        ALAssetsFilter *filter = [self.parentViewController performSelector:@selector(assetsFilter)];
        NSError *error = nil;
//        self.groups = [library
//                       assetsGroupsWithTypes:ALAssetsGroupAll
//                       assetsFilter:filter
//                       error:&error];
        if (error) { [GCImagePickerController failedToLoadAssetsWithError:error]; }
        self.tableView.hidden = ([self.groups count] == 0);
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.tableView reloadData];
//        if (indexPath && (NSUInteger)indexPath.row < [self.groups count]) {
//            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
//        }
    }
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _numberFormatter = [[NSNumberFormatter alloc] init];
    self.tableView.rowHeight = 60.0;
    [self reloadAssets];
}

- (void)didReceiveMemoryWarning {
    if (![self isViewLoaded]) {
        _groups = nil;
        _numberFormatter = nil;
    }
}

#pragma mark - button actions

- (void)done {
    GCImagePickerControllerDidFinishBlock block = [self.parentViewController performSelector:@selector(finishBlock)];
    if (block) { block(); }
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryType = (self.showDisclosureIndicators) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    }
    ALAssetsGroup *group = [self.groups objectAtIndex:indexPath.row];
	cell.textLabel.text = [group valueForProperty:ALAssetsGroupPropertyName];
	cell.imageView.image = [UIImage imageWithCGImage:[group posterImage]];
    NSNumber *count = [NSNumber numberWithInteger:[group numberOfAssets]];
    cell.detailTextLabel.text = [_numberFormatter stringFromNumber:count];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ALAssetsGroup *group = [self.groups objectAtIndex:indexPath.row];
    if (self.delegate) { [self.delegate groupPicker:self didSelectGroup:group]; }
    else {
        GCIPAssetPickerController *assetPicker = [[GCIPAssetPickerController alloc] init];
        assetPicker.groupIdentifier = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
        [self.navigationController pushViewController:assetPicker animated:YES];
    }
}

@end
