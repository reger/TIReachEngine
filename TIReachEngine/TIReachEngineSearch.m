//
//  TIReachEngineSearch.m
//  ReachEngine
//
//  Created by Tom Irving on 05/10/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "TIReachEngineSearch.h"

NSString * const TIReachEngineFileTypeImage = @"Image";
NSString * const TIReachEngineFileTypeGameClip = @"GameClip";
NSString * const TIReachEngineFileTypeGameMap = @"GameMap";
NSString * const TIReachEngineFileTypeGameSettings = @"GameSettings";

NSString * const TIReachEngineMapFilterNone = @"null";

NSString * const TIReachEngineEngineFilterNone = @"null";
NSString * const TIReachEngineEngineFilterCampaign = @"Campaign";
NSString * const TIReachEngineEngineFilterForge = @"Forge";
NSString * const TIReachEngineEngineFilterMultiplayer = @"Multiplayer";
NSString * const TIReachEngineEngineFilterFirefight = @"Firefight";

NSString * const TIReachEngineDateFilterDay = @"Day";
NSString * const TIReachEngineDateFilterWeek = @"Week";
NSString * const TIReachEngineDateFilterMonth = @"Month";
NSString * const TIReachEngineDateFilterAll = @"All";

NSString * const TIReachEngineSortFilterMostRelevant = @"MostRelevant";
NSString * const TIReachEngineSortFilterMostRecent = @"MostRecent";
NSString * const TIReachEngineSortFilterMostDownloads = @"MostDownloads";
NSString * const TIReachEngineSortFilterHighestRated = @"HighestRated";

@implementation TIReachEngineSearch
@synthesize fileType;
@synthesize mapFilter;
@synthesize engineFilter;
@synthesize dateFilter;
@synthesize sortFilter;
@synthesize page;
@synthesize tags;

- (id)initWithFileType:(NSString *)aFileType mapFilter:(NSString *)aMapFilter engineFilter:(NSString *)anEngineFilter 
			dateFilter:(NSString *)aDateFilter sortFilter:(NSString *)aSortFilter page:(NSInteger)aPage tags:(NSArray *)someTags {
	
	if ((self = [super init])){
		
		[self setFileType:aFileType];
		[self setMapFilter:aMapFilter];
		[self setEngineFilter:anEngineFilter];
		[self setDateFilter:aDateFilter];
		[self setSortFilter:aSortFilter];
		[self setPage:aPage];
		[self setTags:someTags];
	}
	
	return self;
}

- (NSString *)safeURLRepresentation {
	
	NSString * tagsString = @"";
	if ([tags count] > 0){
		tagsString = [NSString stringWithFormat:@"?tags=%@", [tags componentsJoinedByString:@";"]];
	}
	
	return [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%i%@", fileType, mapFilter, engineFilter, 
			dateFilter, sortFilter, page, tagsString];
}

- (void)dealloc {
	
	[fileType release];
	[mapFilter release];
	[engineFilter release];
	[dateFilter release];
	[sortFilter release];
	[tags release];
	[super dealloc];
}

@end
