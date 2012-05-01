//
//  PlaceAnnotation.h
//  FlickrBrowser
//
//  Created by Hung Mai on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PlaceAnnotation : NSObject <MKAnnotation>

+ (PlaceAnnotation *)annotationForPlace:(NSDictionary *)place;

@property (nonatomic,strong) NSDictionary *place;

@end
