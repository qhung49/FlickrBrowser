//
//  PhotoViewController.m
//  FlickrBrowser
//
//  Created by Hung Mai on 14/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PhotoViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize photoURL = _photoURL;

- (void)viewWillAppear:(BOOL)animated
{
    CGRect bounds = self.scrollView.bounds;
    CGRect rect = self.imageView.frame;
    CGFloat ratio = bounds.size.height/bounds.size.width;
    if (rect.size.height/rect.size.width > ratio)
    {
        rect.size.height = rect.size.width * ratio;
    }
    else
    {
        rect.size.width = rect.size.height / ratio;
    }
    [self.scrollView zoomToRect:rect animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSData *data = [NSData dataWithContentsOfURL:self.photoURL];
    self.imageView.image = [UIImage imageWithData:data];
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    self.scrollView.contentSize = self.imageView.image.size;
    //self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
