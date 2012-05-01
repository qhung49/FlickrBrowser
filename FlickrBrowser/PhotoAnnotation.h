//
//  FlickrPhotoAnnotation.h
//  Shutterbug
//
//  Created by Hung Mai on 21/4/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PhotoAnnotation : NSObject <MKAnnotation>

+ (PhotoAnnotation *)annotationForPhoto:(NSDictionary *)photo;

@property (nonatomic,strong) NSDictionary *photo;

@end
