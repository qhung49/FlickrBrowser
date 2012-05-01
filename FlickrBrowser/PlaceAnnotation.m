//
//  PlaceAnnotation.m
//  FlickrBrowser
//
//  Created by Hung Mai on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceAnnotation.h"
#import "FlickrFetcher.h"

@interface PlaceAnnotation ()

@property (nonatomic,strong) NSDictionary *cityState;

@end

@implementation PlaceAnnotation

@synthesize place = _place;
@synthesize cityState = _cityState;

+(PlaceAnnotation *)annotationForPlace:(NSDictionary *)place
{
    PlaceAnnotation *annotation = [[PlaceAnnotation alloc] init];
    annotation.place = place;
    annotation.cityState = [FlickrFetcher cityAndStateFromPlaceName:[place objectForKey:FLICKR_PLACE_NAME]];
    return annotation;
}

- (NSString *)title
{
    return [self.cityState objectForKey:@"city"];
}

- (NSString *) subtitle
{
    return [self.cityState objectForKey:@"state"];
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}

@end
