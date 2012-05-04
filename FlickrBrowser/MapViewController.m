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
     MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in mapView.annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    zoomRect = [mapView mapRectThatFits:zoomRect];
    [mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsFromString(@"{3,3,3,3}") animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.mapView.delegate = self;
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
            PhotoViewController *photoVC = [self.splitViewController.viewControllers lastObject];
            // in case of iPad, set master view controller
            if (photoVC)
            {
                PhotoAnnotation *photoAnnotation = view.annotation;
                NSDictionary *photo = photoAnnotation.photo;
                NSURL *url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatOriginal];
                
                // original format not available, fall back to large
                if (!url) url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
                [photoVC setTitle:photoAnnotation.title];
                [photoVC setPhotoURL:url];
            }
            else {
                [self performSegueWithIdentifier:@"Display Photo" sender:view.annotation];    
            }
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
    if (self.annotationsArePhoto)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        dispatch_queue_t downloadQueue = dispatch_queue_create("map thumbnail downloader", NULL);
        dispatch_async(downloadQueue, ^{
            PhotoAnnotation *photoAnnotation = view.annotation;
            NSURL *url = [FlickrFetcher urlForPhoto:photoAnnotation.photo format:FlickrPhotoFormatSquare];
            NSData *data =[NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:data]; 
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                if (view.hidden) return;
                [(UIImageView *)view.leftCalloutAccessoryView setImage:image];
            });
        });
        dispatch_release(downloadQueue);
    }
}

-(void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (IBAction)changeMapType:(UISegmentedControl *)sender 
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}

@end
