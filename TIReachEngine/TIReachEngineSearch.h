//
//  TIReachEngineSearch.h
//  ReachEngine
//
//  Created by Tom Irving on 05/10/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "TIReachEngineGlobal.h"

extern NSString * const TIReachEngineFileTypeImage;
extern NSString * const TIReachEngineFileTypeGameClip;
extern NSString * const TIReachEngineFileTypeGameMap;
extern NSString * const TIReachEngineFileTypeGameSettings;
extern NSString * const TIReachEngineMapFilterNone;
extern NSString * const TIReachEngineEngineFilterNone;
extern NSString * const TIReachEngineEngineFilterCampaign;
extern NSString * const TIReachEngineEngineFilterForge;
extern NSString * const TIReachEngineEngineFilterMultiplayer;
extern NSString * const TIReachEngineEngineFilterFirefight;
extern NSString * const TIReachEngineDateFilterDay;
extern NSString * const TIReachEngineDateFilterWeek;
extern NSString * const TIReachEngineDateFilterMonth;
extern NSString * const TIReachEngineDateFilterAll;
extern NSString * const TIReachEngineSortFilterMostRelevant;
extern NSString * const TIReachEngineSortFilterMostRecent;
extern NSString * const TIReachEngineSortFilterMostDownloads;
extern NSString * const TIReachEngineSortFilterMostRelevant;
extern NSString * const TIReachEngineSortFilterHighestRated;

@interface TIReachEngineSearch : NSObject {

	NSString * fileType;
	NSString * mapFilter;
	NSString * engineFilter;
	NSString * dateFilter;
	NSString * sortFilter;
	NSInteger page;
	NSArray * tags;
}

@property (nonatomic, retain) NSString * fileType;
@property (nonatomic, retain) NSString * mapFilter;
@property (nonatomic, retain) NSString * engineFilter;
@property (nonatomic, retain) NSString * dateFilter;
@property (nonatomic, retain) NSString * sortFilter;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, retain) NSArray * tags;

- (id)initWithFileType:(NSString *)aFileType mapFilter:(NSString *)aMapFilter engineFilter:(NSString *)anEngineFilter 
			dateFilter:(NSString *)aDateFilter sortFilter:(NSString *)aSortFilter page:(NSInteger)aPage tags:(NSArray *)someTags;

- (NSString *)safeURLRepresentation;

@end
