//
//  PhotoCache.m
//  FlickrBrowser
//
//  Created by Hung Mai on 30/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoCache.h"

#define PHOTO_CACHE_DIRECTORY @"PhotoCache"
#define PHOTO_CACHE_DIRECTORY_MAX_SIZE 10000000

@interface PhotoCache ()

@property (nonatomic,strong) NSString* cacheDirectory;
@property (nonatomic,strong) NSString* cacheFile;
@property (nonatomic) unsigned long long cacheDirectorySize;

@end

@implementation PhotoCache

@synthesize url = _url;
@synthesize cacheDirectorySize=_cacheDirectorySize;
@synthesize cacheDirectory = _cacheDirectory;
@synthesize cacheFile = _cacheFile;

- (NSString *)cacheDirectory
{
    if (!_cacheDirectory)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _cacheDirectory = [[paths lastObject] stringByAppendingPathComponent:PHOTO_CACHE_DIRECTORY];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_cacheDirectory]) 
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:_cacheDirectory
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:nil];
            self.cacheDirectorySize = 0;
        }
        else {
            NSArray *filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_cacheDirectory error:nil];
            for (NSString *fileName in filesArray) {
                NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:fileName] error:nil];
                self.cacheDirectorySize += [attributes fileSize];
            }
        }
    }
    return _cacheDirectory;
}

- (UIImage *)image
{
    UIImage *theImage;
    // check availability of photoURL in cache
    NSString *fileName = [[self.url path] lastPathComponent];
    self.cacheFile = [self.cacheDirectory stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.cacheFile]) 
    {
        // if yes, load from cache
        theImage = [UIImage imageWithContentsOfFile:self.cacheFile];
    }
    else
    {
        // else, load from url
        NSData *data =[NSData dataWithContentsOfURL:self.url];
        theImage = [UIImage imageWithData:data];
        // and save to cache
        [[NSFileManager defaultManager] createFileAtPath:self.cacheFile contents:data attributes:nil];
        self.cacheDirectorySize += [[NSFileManager defaultManager] attributesOfItemAtPath:self.cacheFile error:nil].fileSize;
        if (self.cacheDirectorySize > PHOTO_CACHE_DIRECTORY_MAX_SIZE)
        {
            // delete oldest photo
            NSMutableArray *filesArray = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:_cacheDirectory error:nil] mutableCopy];
            [filesArray sortUsingComparator:^NSComparisonResult(id obj1,id obj2) {
                NSDictionary *attributes1 = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:obj1] error:nil];
                NSDictionary *attributes2 = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:obj2] error:nil];
                return [attributes1.fileCreationDate compare:attributes2.fileCreationDate];
            }];
            while (self.cacheDirectorySize>PHOTO_CACHE_DIRECTORY_MAX_SIZE)
            {
                NSString* fullFilePath = [self.cacheDirectory stringByAppendingPathComponent:[filesArray  objectAtIndex:0]];
                self.cacheDirectorySize -= [[NSFileManager defaultManager] attributesOfItemAtPath:fullFilePath error:nil].fileSize;
                [[NSFileManager defaultManager] removeItemAtPath:fullFilePath error:nil];
                [filesArray removeObjectAtIndex:0];
            }
        }
    }
    
    return theImage;
}

@end
