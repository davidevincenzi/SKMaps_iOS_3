//
//  SKODefinitions.h
//  SKOSearchLib
//
//  Created by Mihai Costea on 15/04/15.
//  Copyright (c) 2016 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, SKOFoursquareSortOrder)
{
    SKOFoursquareSortOrderRelevance,
    SKOFoursquareSortOrderDistance
};

typedef NS_ENUM (NSInteger, SKOTripAdvisorPOIType)
{
    SKOTripAdvisorPOITypeUndefined,
    SKOTripAdvisorPOITypeHotel,
    SKOTripAdvisorPOITypeRestaurant,
    SKOTripAdvisorPOITypeThingsToDo
};

typedef NS_ENUM (NSInteger, SKOTripAdvisorSortOrder)
{
    SKOTripAdvisorSortOrderDistance,
    SKOTripAdvisorSortOrderPopularity
};

typedef NS_ENUM (NSInteger, SKOYelpSortOrder)
{
    SKOYelpSortOrderBestMatched = 0,
    SKOYelpSortOrderDistance,
    SKOYelpSortOrderHighestRated
};

typedef NS_ENUM (NSInteger, SKOGooglePlacesSortOrder)
{
    SKOGoogleSortOrderProminence = 0,
    SKOGoogleSortOrderDistance
};

typedef NS_ENUM (NSInteger, SKOSearchMode)
{
    SKOSearchOnline = 0,
    SKOSearchOffline = 1
    
    //TODO: (ZK) delta change
    //temporarily commenting the code
    //SKOSearchHybrid = 2
};