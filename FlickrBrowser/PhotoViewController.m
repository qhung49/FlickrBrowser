//
//  PhotoViewController.m
//  FlickrBrowser
//
//  Created by Hung Mai on 14/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotoCache.h"

@interface PhotoViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic) BOOL viewAppeared;
@property (nonatomic,strong) PhotoCache *photoCache;

- (void) refreshView;
- (void) zoomToOptimalRect;

@end

@implementation PhotoViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize toolbar = _toolbar;
@synthesize photoURL = _photoURL;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize spinner = _spinner;
@synthesize viewAppeared = _viewAppeared;
@synthesize photoCache = _photoCache;

#pragma mark Setters/Getters

- (void)setPhotoURL:(NSURL *)photoURL
{
    _photoURL = photoURL;
    if (self.viewAppeared) [self refreshView];
}

- (PhotoCache *)photoCache
{
    if (!_photoCache)
    {
        _photoCache = [[PhotoCache alloc] init];
    }
    return _photoCache;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.viewAppeared = YES;
    if (self.photoURL) [self refreshView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.scrollView.delegate = self;
    self.splitViewController.delegate = self;
    self.viewAppeared = NO;
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setImageView:nil];
    [self setToolbar:nil];
    [self setSpinner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark PhotoViewController

- (void) refreshView
{
    [self.spinner startAnimating];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSURL *currentURL = self.photoURL;
        self.photoCache.url = self.photoURL;
        UIImage *image = self.photoCache.image;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![self.navigationController.visibleViewController isEqual:self]) return; // visible view controller has changed
            if (![currentURL isEqual:self.photoURL]) return; // model has changed
            [self.spinner stopAnimating];
            self.imageView.image = image;
            self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
            self.scrollView.zoomScale = 1;
            self.scrollView.contentSize = self.imageView.image.size;
            //self.scrollView.bounces = NO;
            [self zoomToOptimalRect];
        });
    });
    dispatch_release(downloadQueue);
}

- (void)zoomToOptimalRect
{
    CGRect bounds = self.scrollView.bounds;
    CGRect rect = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height);
    CGFloat ratio = bounds.size.height/bounds.size.width;
    if (rect.size.height/rect.size.width > ratio)
    {
        rect.size.height = rect.size.width * ratio;
    }
    else
    {
        rect.size.width = rect.size.height / ratio;
    }
    self.scrollView.maximumZoomScale = MAX(rect.size.height/bounds.size.height, rect.size.width/bounds.size.width);
    self.scrollView.minimumZoomScale = MIN(bounds.size.height/rect.size.height, bounds.size.width/rect.size.width);
    NSLog(@"Scale min = %f, max = %f",self.scrollView.minimumZoomScale,self.scrollView.maximumZoomScale);
    [self.scrollView zoomToRect:rect animated:YES];
}

#pragma mark UISplitViewControllerDelegate
- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Main Browser";    
    self.splitViewBarButtonItem = barButtonItem;
    self.toolbar.hidden = NO;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.splitViewBarButtonItem = nil;
    self.toolbar.hidden = YES;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

@end
