//
//  TIReachEngine.h
//  TIReachEngine
//
//  Created by Tom Irving on 20/09/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "TIReachEngineGlobal.h"
#import "TIReachEngineDelegate.h"
#import "TIReachEngineSearch.h"

extern NSString * const TIReachEngineConnectionGamertagKey;
extern NSString * const TIReachEngineConnectionPageNumberKey;
extern NSString * const TIReachEngineConnectionGameTypeKey;
extern NSString * const TIReachEngineConnectionSearchIDKey;
extern NSString * const TIReachEngineConnectionStatsTypeKey;
extern NSString * const TIReachEngineConnectionSearchQueryKey;
extern NSString * const TIReachEngineConnectionResponseStatusCodeKey;
extern NSString * const TIReachEngineGameTypeAll;
extern NSString * const TIReachEngineGameTypeCampaign;
extern NSString * const TIReachEngineGameTypeFirefight;
extern NSString * const TIReachEngineGameTypeCompetitive;
extern NSString * const TIReachEngineGameTypeArena;
extern NSString * const TIReachEngineGameTypeInvasion;
extern NSString * const TIReachEngineGameTypeCustom;
extern NSString * const TIReachEngineStatsTypeNone;
extern NSString * const TIReachEngineStatsTypeByMap;
extern NSString * const TIReachEngineStatsTypeByPlaylist;

@class TIReachEngineConnection, TIReachEngineSearch;

@interface TIReachEngine : NSObject {
	
	id <TIReachEngineDelegate> delegate;
	NSMutableDictionary * returnDataDict;
	
	NSString * APIRoot;
	NSString * APIKey;
}

@property (nonatomic, assign) id <TIReachEngineDelegate> delegate;

@property (nonatomic, retain) NSString * APIRoot;
@property (nonatomic, retain) NSString * APIKey;

- (id)initWithAPIKey:(NSString *)aKey delegate:(id<TIReachEngineDelegate>)aDelegate;
+ (TIReachEngine *)reachEngineWithAPIKey:(NSString *)aKey delegate:(id<TIReachEngineDelegate>)aDelegate;

- (TIReachEngineConnection *)getGameMetadata;
- (TIReachEngineConnection *)getGamesforPlayer:(NSString *)gamertag ofGameType:(NSString *)gameType forPage:(NSInteger)page;
- (TIReachEngineConnection *)getGameDetailsForGameID:(NSString *)gameID;
- (TIReachEngineConnection *)getPlayerDetails:(NSString *)gamertag withStatsType:(NSString *)statsType;
- (TIReachEngineConnection *)getFileShareForPlayer:(NSString *)gamertag;
- (TIReachEngineConnection *)getFileDetailsForFileID:(NSString *)fileID;
- (TIReachEngineConnection *)getFileSetsForPlayer:(NSString *)gamertag;
- (TIReachEngineConnection *)getFilesForFileSetID:(NSString *)fileSetID player:(NSString *)gamertag;
- (TIReachEngineConnection *)getRecentScreenshotsForPlayer:(NSString *)gamertag;
- (TIReachEngineConnection *)getRenderedVideosForPlayer:(NSString *)gamertag page:(NSInteger)page;
- (TIReachEngineConnection *)getResultsForSearch:(TIReachEngineSearch *)search;
- (TIReachEngineConnection *)getChallenges;

@end
