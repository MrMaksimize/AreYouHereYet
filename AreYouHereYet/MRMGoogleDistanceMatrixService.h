//
//  MRMGoogleDistanceMatrixService.h
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 8/13/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRMGoogleDistanceMatrixService : NSObject

@property (nonatomic, strong) NSString *notificationName;

- (id) initWithNotificationName:(NSString *)notificationName;
- (void) getDistancesFromOrigins:(NSArray *)origins toDestinations:(NSArray *)destinations;


@end
