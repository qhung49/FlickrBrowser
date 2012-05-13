//
//  VacationHelper.m
//  FlickrBrowser
//
//  Created by Hung Mai on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationHelper.h"

@implementation VacationHelper

static NSMutableDictionary *databases;

+ (void)initManagedDocumentForVacation:(NSString *)vacationName
{
    
}

+(void)openVacation:(NSString *)vacationName usingBlock:(completion_block_t)completionBlock
{
    if (databases != nil && [databases objectForKey:vacationName] != nil) {
    }
    else {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // create UIManagedDocument
            NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            url = [url URLByAppendingPathComponent:@"Vacations"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
                [[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
            }
            url = [url URLByAppendingPathComponent:vacationName];
            UIManagedDocument *databaseToAdd = [[UIManagedDocument alloc] initWithFileURL:url];
            // add to databases
            if (!databases) {
                databases = [NSMutableDictionary dictionaryWithObject:databaseToAdd forKey:vacationName];
            }
            else {
                [databases setObject:databaseToAdd forKey:vacationName];
            }
        });
    }
    
    // at this point, database is valid
    UIManagedDocument *database = [databases objectForKey:vacationName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[database.fileURL path]]) {
        // does not exist on disk, so create it
        [database saveToURL:database.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) completionBlock(database);
        }];
    } else if (database.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [database openWithCompletionHandler:^(BOOL success) {
            if (success) completionBlock(database);
        }];
    } else if (database.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        completionBlock(database);    
    }
    
}

@end
