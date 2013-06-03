//
//  Copyright (c) 2013, Phillip Caudell
//  All rights reserved.

//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "PCMapImage.h"

@interface PCMapImage()
{
    MKMapView *_mapView;
    renderCompletion _completion;
    __strong id _objectRetainer;
}

- (void)PC_startRender;
- (void)PC_removeLegalNotice;
- (void)PC_createSnapshot;
- (void)PC_mapViewDidFinishLoading;
- (NSString *)PC_hash;

@end

@implementation PCMapImage

+ (id)renderImageWithCoordinate:(CLLocationCoordinate2D)coordinate region:(MKCoordinateRegion)region size:(CGSize)size showAnnotation:(BOOL)showAnnotation renderCompletion:(renderCompletion)renderCompletion
{
    return [[PCMapImage alloc] initWithCoordinate:coordinate region:region size:size showAnnotation:showAnnotation renderCompletion:renderCompletion];
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate region:(MKCoordinateRegion)region size:(CGSize)size showAnnotation:(BOOL)showAnnotation renderCompletion:(renderCompletion)renderCompletion
{
    self = [super init];
    if (self) {
        
        // Need to keep reference or ARC will try and shut this club DOWN.
        _objectRetainer = self;
        
        _coordinate = coordinate;
        _region = region;
        _size = size;
        _showAnnotation = showAnnotation;
        _completion = renderCompletion;
    
        [self PC_startRender];
                
    }
    return self;
}

- (void)PC_startRender
{
    // Check cache first
    UIImage *cachedImage = [[PCMapImageCacheController sharedController] cachedImageWithHash:[self PC_hash]];
    
    if (cachedImage) {
        _completion(cachedImage, nil);
        return;
    }
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(-_size.width, -_size.height, _size.width, _size.height)];
    _mapView.delegate = self;
    
    [_mapView setCenterCoordinate:_coordinate];
    [_mapView setRegion:_region];
    
    [self PC_removeLegalNotice];
    
    // MKMapView won't render unless it's "on screen", so use the window to get it going.
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:_mapView];
    
    if (_showAnnotation) {
        
        PCMapImageAnnotation *annotation = [[PCMapImageAnnotation alloc] init];
        annotation.coordinate = _coordinate;
        [_mapView addAnnotation:annotation];
        
    }
}

#pragma mark MKMapView delegate

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    // Unfortunatly mapViewDidFinishLoadingMap is always fired prematurely, so we have to create a faux delay. Hopefully Apple fix this once they fixing the actual maps themselves. *iOS 6 MAP JOKE KLAXON*
    [NSTimer scheduledTimerWithTimeInterval:kPCMapImageSnapshotOffsetInterval target:self selector:@selector(PC_mapViewDidFinishLoading) userInfo:nil repeats:NO];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    _completion(nil, error);
    _objectRetainer = nil;
}

#pragma mark Helper methods

- (void)PC_mapViewDidFinishLoading
{
    [self PC_createSnapshot];
    _completion(_image, nil);
    _objectRetainer = nil;
}

- (void)PC_removeLegalNotice
{
    // The legal notice is just a UILabel ontop of the MKMapView. Would be preferable to check for MKAttributionLabel, but it's a private class. *Apple rejection klaxon*
    for (UIView *view in _mapView.subviews){
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)PC_createSnapshot
{
    // Just grab the context - nice and easy. *hair swoosh*
    UIGraphicsBeginImageContextWithOptions(_mapView.bounds.size, YES, [[UIScreen mainScreen] scale]);
    [_mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
    _image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Cache away
    [[PCMapImageCacheController sharedController] cacheImage:_image hash:[self PC_hash]];
}

- (NSString *)PC_hash
{
    NSString *hash = [NSString stringWithFormat:@"%f%f%f%f%f%f%i", _coordinate.longitude, _coordinate.latitude, _region.span.latitudeDelta, _region.span.longitudeDelta, _size.width, _size.height, _showAnnotation];
    
    return [NSString stringWithFormat:@"%i", [hash hash ]];
}

@end

@implementation PCMapImageAnnotation


@end

@implementation PCMapImageCacheController

static PCMapImageCacheController *sharedController = nil;

+ (PCMapImageCacheController *)sharedController
{
    @synchronized(self) {
        if (sharedController == nil) {
            sharedController = [[self alloc] init];
        }
    }
    return sharedController;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)cacheImage:(UIImage *)image hash:(NSString *)hash
{
    [self.cache setObject:image forKey:hash];
}

- (UIImage *)cachedImageWithHash:(NSString *)hash
{
    return [self.cache objectForKey:hash];
}

@end
