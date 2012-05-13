//
//  VacationHelper.h
//  FlickrBrowser
//
//  Created by Hung Mai on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completion_block_t)(UIManagedDocument *database);

@interface VacationHelper : NSObject

+ (void)openVacation:(NSString *)vacationName usingBlock:(completion_block_t)completionBlock;

@end
