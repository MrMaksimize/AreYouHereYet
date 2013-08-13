//
//  MRMGoogleDistanceMatrixService.m
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 8/13/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import "MRMGoogleDistanceMatrixService.h"
#import <AFNetworking/AFJSONRequestOperation.h>



@implementation MRMGoogleDistanceMatrixService {
    NSArray *originStore;
    NSArray *destinationStore;
}

static NSString *kMRMGoogleDistanceMatrixURL = @"http://maps.googleapis.com/maps/api/distancematrix/json";
static NSString *kMRMGoogleDistanceMatrixURLSecure = @"https://maps.googleapis.com/maps/api/distancematrix/json";

- (id)initWithNotificationName:(NSString *)notificationName
{
    if (self = [super init]) {
        self.notificationName = notificationName;
    }
    return self;
}

- (void)getDistancesFromOrigins:(NSArray *)origins toDestinations:(NSArray *)destinations {
    NSString *originQuery = [NSString
                             stringWithFormat:@"%@=%@", @"origin", [origins componentsJoinedByString:@"|"]];
    NSString *destinationQuery = [NSString
                                  stringWithFormat:@"%@=%@", @"destination", [destinations componentsJoinedByString:@"|"]];






}





@end
