//
//  TIReachEngineDelegate.h
//  TIReachEngine
//
//  Created by Tom Irving on 20/09/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "TIReachEngineGlobal.h"

@class TIReachEngine, TIReachEngineConnection, TIReachEngineSearch;

@protocol TIReachEngineDelegate <NSObject>
@optional

//========================================================================
// Called whenever something fails, whether it be no connection,
// an invalid user name or not being authorised.
//========================================================================
- (void)reachEngine:(TIReachEngine *)reachEngine 
		 connection:(TIReachEngineConnection *)connection 
   didFailWithError:(NSError *)error;

//========================================================================
// Called when a request for metadata comes back successfully.
//========================================================================
- (void)reachEngine:(TIReachEngine *)reachEngine 
 didReceiveMetadata:(NSDictionary *)metadata 
	  forConnection:(TIReachEngineConnection *)connection;

//========================================================================
// Called when a request for games comes back successfully.
//========================================================================
- (void)reachEngine:(TIReachEngine *)reachEngine 
	didReceiveGames:(NSDictionary *)games 
		forPlayer:(NSString *)gamertag 
	   ofGameType:(NSString *)gameType 
			 forPage:(NSInteger)page 
		 connection:(TIReachEngineConnection *)connection;

//========================================================================
// Called when a request for game details comes back successfully.
//========================================================================
- (void)reachEngine:(TIReachEngine *)reachEngine 
didReceiveGameDetails:(NSDictionary *)details 
		  forGameID:(NSString *)gameID 
		 connection:(TIReachEngineConnection *)connection;

//========================================================================
// Called when a request for player details comes back successfully.
//========================================================================
- (void)reachEngine:(TIReachEngine *)reachEngine 
didReceivePlayerDetails:(NSDictionary *)details 
		  forPlayer:(NSString *)gamertag 
		 connection:(TIReachEngineConnection *)connection;

//========================================================================
// Called when a request for a player's file share comes back successfully.
//========================================================================
- (void)reachEngine:(TIReachEngine *)reachEngine 
didReceiveFileShare:(NSDictionary *)fileShare 
		  forPlayer:(NSString *)gamertag 
		 connection:(TIReachEngineConnection *)connection;

//========================================================================
// Called when a request for file details comes back successfully.
//========================================================================
- (void)reachEngine:(TIReachEngine *)reachEngine 
didReceiveFileDetails:(NSDictionary *)details 
		  forFileID:(NSString *)fileID 
		 connection:(TIReachEngineConnection *)connection;

//========================================================================
// Called when a request for a player's file sets comes back successfully.
//========================================================================
- (void)reachEngine:(TIReachEngine *)reachEngine 
 didReceiveFileSets:(NSDictionary *)fileSets 
		  forPlayer:(NSString *)gamertag 
		 connection:(TIReachEngineConnection *)connection;

//========================================================================
// Called when a request for a file set's file details 
// comes back successfully.
//========================================================================
- (void)reachEngine:(TIReachEngine *)reachEngine 
didReceiveFileSetFiles:(NSDictionary *)details 
	   forFileSetID:(NSString *)fileSetID 
			 player:(NSString *)gamertag 
		 connection:(TIReachEngineConnection *)connection;

//========================================================================
// Called when a request for a player's screenshots comes back successfully.
//========================================================================
- (void)reachEngine:(TIReachEngine *)reachEngine 
didReceiveScreenshots:(NSDictionary *)screenshots 
		  forPlayer:(NSString *)gamertag 
		 connection:(TIReachEngineConnection *)connection;

//========================================================================
// Called when a request for a player's rendered videos 
// comes back successfully.
//========================================================================
- (void)reachEngine:(TIReachEngine *)reachEngine 
didReceiveRenderedVideos:(NSDictionary *)videos 
		  forPlayer:(NSString *)gamertag 
			   page:(NSInteger)page
		 connection:(TIReachEngineConnection *)connection;

//========================================================================
// Called when search results come back successfully.
//========================================================================
- (void)reachEngine:(TIReachEngine *)reachEngine 
didReceiveSearchResults:(NSDictionary *)results 
		  forSearch:(TIReachEngineSearch *)search 
		 connection:(TIReachEngineConnection *)connection;

//========================================================================
// Called when a request for challenges comes back successfully.
//========================================================================
- (void)reachEngine:(TIReachEngine *)reachEngine 
 didReceiveChallenges:(NSDictionary *)challenges 
	  forConnection:(TIReachEngineConnection *)connection;

@end
