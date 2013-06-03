//
//  Copyright (c) 2013, Phillip Caudell
//  All rights reserved.

//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/Foundation.h>

#define kPCMapImageSnapshotOffsetInterval 1.5

@interface PCMapImage : NSObject <MKMapViewDelegate>

typedef void (^renderCompletion)(UIImage *image, NSError *error);

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) MKCoordinateRegion region;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) BOOL showAnnotation;

/**
 Renders a UIImage representation of an MKMapView.
 @param coordinate The coordinate to center the map view.
 @param region The region to center the map view.
 @param size The size at which to render the map view.
 @param showAnnotation Whether a pin annotation should be drawn on the view
 @param renderCompletion The completion handler that is called once the render is complete.
 */
+ (id)renderImageWithCoordinate:(CLLocationCoordinate2D)coordinate region:(MKCoordinateRegion)region size:(CGSize)size showAnnotation:(BOOL)showAnnotation renderCompletion:(renderCompletion)renderCompletion;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate region:(MKCoordinateRegion)region size:(CGSize)size showAnnotation:(BOOL)showAnnotation renderCompletion:(renderCompletion)renderCompletion;

@end

@interface PCMapImageAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@interface PCMapImageCacheController : NSObject

@property (nonatomic, strong) NSCache *cache;

+ (PCMapImageCacheController *)sharedController;

- (void)cacheImage:(UIImage *)image hash:(NSString *)hash;
- (UIImage *)cachedImageWithHash:(NSString *)hash;

@end