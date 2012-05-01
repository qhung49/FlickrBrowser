//
//  MapViewController.m
//  FlickrBrowser
//
//  Created by Hung Mai on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "MapKit/MapKit.h"
#import "FlickrFetcher.h"
#import "PhotoAnnotation.h"
#import "PlaceAnnotation.h"
#import "PhotoViewController.h"
#import "PhotoTableViewController.h"

#define ANNOTATION_IDENTIFIER @"Annotation"

@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic,strong) NSArray* annotations; //of id<MKAnnotation>

- (NSArray *)annotationsFromModel;
-(void)zoomToFitMapAnnotations:(MKMapView*)mapView;

@end

@implementation MapViewController

@synthesize model = _model;
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize annotationsArePhoto = _annotationsArePhoto;

-(void)setModel:(NSArray *)model
{
    _model = model;
    self.annotations = [self annotationsFromModel];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self refreshView];
}

- (NSArray *)annotationsFromModel
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.model count]];
    for (NSDictionary *item in self.model)
    {
        if (self.annotationsArePhoto) [annotations addObject:[PhotoAnnotation annotationForPhoto:item]];
        else [annotations addObject:[PlaceAnnotation annotationForPlace:item]];
    }
    return annotations;
}

- (void)refreshView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.annotations];
    
    [self zoomToFitMapAnnotations:self.mapView];
}

-(void)zoomToFitMapAnnotations:(MKMapView*)mapView
{
    if([mapView.annotations count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id<MKAnnotation> annotation in mapView.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.2; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.2; // Add a little extra space on the sides
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.mapView.delegate = self;
    [self refreshView];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:ANNOTATION_IDENTIFIER];
    if (!aView)
    {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ANNOTATION_IDENTIFIER];
        aView.canShowCallout = YES;
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        aView.rightCalloutAccessoryView = rightButton;
        if (self.annotationsArePhoto) aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    aView.annotation = annotation;
    if (self.annotationsArePhoto) [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    return aView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([control isKindOfClass:[UIButton class]])
    {
        if (self.annotationsArePhoto)
        {
            // maps of photo, show the photo
            [self performSegueWithIdentifier:@"Display Photo" sender:view.annotation];
        }
        else {
            [self performSegueWithIdentifier:@"Show Photo List" sender:view.annotation];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Display Photo"]) {
        PhotoViewController *photoVC = segue.destinationViewController;
        PhotoAnnotation *photoAnnotation = sender;
        
        NSURL *url = [FlickrFetcher urlForPhoto:photoAnnotation.photo format:FlickrPhotoFormatOriginal];
        // original format not available, fall back to large
        if (!url) url = [FlickrFetcher urlForPhoto:photoAnnotation.photo format:FlickrPhotoFormatLarge];
        
        [photoVC setTitle:photoAnnotation.title];
        [photoVC setPhotoURL:url];
    }
    else if ([segue.identifier isEqualToString:@"Show Photo List"]) {
        PlaceAnnotation *placeAnnotation = sender;
        [segue.destinationViewController setTitle:placeAnnotation.title];
        [segue.destinationViewController setPlace:placeAnnotation.place];
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    // load image
    //UIImage *image = [self.delegate mapViewController:self imageForAnnotation:view.annotation];
    //[(UIImageView *)view.leftCalloutAccessoryView setImage:image];
    if (self.annotationsArePhoto)
    {
        dispatch_queue_t downloadQueue = dispatch_queue_create("map thumbnail downloader", NULL);
        dispatch_async(downloadQueue, ^{
            PhotoAnnotation *photoAnnotation = view.annotation;
            NSURL *url = [FlickrFetcher urlForPhoto:photoAnnotation.photo format:FlickrPhotoFormatSquare];
            NSData *data =[NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:data]; 
            dispatch_async(dispatch_get_main_queue(), ^{
                if (view.hidden) return;
                [(UIImageView *)view.leftCalloutAccessoryView setImage:image];
            });
        });
        dispatch_release(downloadQueue);
    }
}

@end
