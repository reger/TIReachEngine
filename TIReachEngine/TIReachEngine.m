//
//  TIReachEngine.m
//  TIReachEngine
//
//  Created by Tom Irving on 20/09/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "TIReachEngine.h"
#import "TIReachEngineConnection.h"
#import "JSON.h"

#define API_ROOT @"http://www.bungie.net/api/reach/reachapijson.svc/"
#define ERROR_DOMAIN @"TIReachEngineErrorDomain"

NSString * const TIReachEngineConnectionGamertagKey = @"TIReachEngineConnectionGamertagKey";
NSString * const TIReachEngineConnectionPageNumberKey = @"TIReachEngineConnectionPageNumberKey";
NSString * const TIReachEngineConnectionGameTypeKey = @"TIReachEngineConnectionGameTypeKey";
NSString * const TIReachEngineConnectionSearchIDKey = @"TIReachEngineConnectionSearchIDKey";
NSString * const TIReachEngineConnectionStatsTypeKey = @"TIReachEngineConnectionStatsTypeKey";
NSString * const TIReachEngineConnectionSearchQueryKey = @"TIReachEngineConnectionSearchQueryKey";
NSString * const TIReachEngineConnectionResponseStatusCodeKey = @"TIReachEngineConnectionResponseStatusCodeKey";

NSString * const TIReachEngineGameTypeAll = @"Unknown";
NSString * const TIReachEngineGameTypeCampaign = @"Campaign";
NSString * const TIReachEngineGameTypeFirefight = @"Firefight";
NSString * const TIReachEngineGameTypeCompetitive = @"Competitive";
NSString * const TIReachEngineGameTypeArena = @"Arena";
NSString * const TIReachEngineGameTypeInvasion = @"Invasion";
NSString * const TIReachEngineGameTypeCustom = @"Custom";

NSString * const TIReachEngineStatsTypeNone = @"nostats";
NSString * const TIReachEngineStatsTypeByMap = @"bymap";
NSString * const TIReachEngineStatsTypeByPlaylist = @"byplaylist";

#pragma mark -
@interface TIReachEngine (Private)
- (NSMutableURLRequest *)_requestWithURL:(NSURL *)URL;
- (TIReachEngineConnection *)_connectionWithRequest:(NSURLRequest *)request type:(TIReachEngineConnectionType)connectionType;
- (void)_notifyDelegateOfError:(NSError *)error forConnection:(TIReachEngineConnection *)connection;
- (void)_notifyDelegateOfMetadata:(NSDictionary *)metadata forConnection:(TIReachEngineConnection *)connection;
- (void)_notifyDelegateOfGames:(NSDictionary *)games forConnection:(TIReachEngineConnection *)connection;
- (void)_notifyDelegateOfGameDetails:(NSDictionary *)details forConnection:(TIReachEngineConnection *)connection;
- (void)_notifyDelegateOfPlayerDetails:(NSDictionary *)details forConnection:(TIReachEngineConnection *)connection;
- (void)_notifyDelegateOfFileShare:(NSDictionary *)fileShare forConnection:(TIReachEngineConnection *)connection;
- (void)_notifyDelegateOfFileDetails:(NSDictionary *)details forConnection:(TIReachEngineConnection *)connection;
- (void)_notifyDelegateOfFileSets:(NSDictionary *)fileSets forConnection:(TIReachEngineConnection *)connection;
- (void)_notifyDelegateOfFileSetFiles:(NSDictionary *)fileSetFiles forConnection:(TIReachEngineConnection *)connection;
- (void)_notifyDelegateOfScreenshots:(NSDictionary *)screenshots forConnection:(TIReachEngineConnection *)connection;
- (void)_notifyDelegateOfRenderedVideos:(NSDictionary *)videos forConnection:(TIReachEngineConnection *)connection;
- (void)_notifyDelegateOfSearchResults:(NSDictionary *)results forConnection:(TIReachEngineConnection *)connection;
- (void)_notifyDelegateOfChallenges:(NSDictionary *)challenges forConnection:(TIReachEngineConnection *)connection;
@end


#pragma mark -
@implementation TIReachEngine
@synthesize delegate;
@synthesize APIRoot;
@synthesize APIKey;

#pragma mark Init Methods
- (id)init {
	return [self initWithAPIKey:@"" delegate:nil];
}

- (id)initWithAPIKey:(NSString *)aKey delegate:(id<TIReachEngineDelegate>)aDelegate {
	
	if ((self = [super init])){
		APIKey = [[NSString alloc] initWithString:aKey];
		delegate = aDelegate;
		returnDataDict = [[NSMutableDictionary alloc] init];
		APIRoot = [[NSString alloc] initWithString:API_ROOT];
	}
	
	return self;
}

+ (TIReachEngine *)reachEngineWithAPIKey:(NSString *)aKey delegate:(id<TIReachEngineDelegate>)aDelegate {
	return [[[self alloc] initWithAPIKey:aKey delegate:aDelegate] autorelease];
}

- (void)setAPIRoot:(NSString *)aRoot {
	
	NSString * theRoot = aRoot;
	if (!theRoot || [theRoot isEqualToString:@""]){
		theRoot = [NSString stringWithString:API_ROOT];
	}
	
	NSString * lastLetter = [theRoot substringWithRange:NSMakeRange(aRoot.length - 1, 1)];
	
	if (![lastLetter isEqualToString:@"/"]){
		theRoot = [theRoot stringByAppendingString:@"/"];
	}
	
	if (APIRoot != theRoot){
		[APIRoot release];
		APIRoot = [theRoot retain];
	}
}

#pragma mark -
#pragma mark Get Connections

- (TIReachEngineConnection *)getGameMetadata {
	
	NSString * URLFormat = [[NSString alloc] initWithFormat:@"%@game/metadata/%@", APIRoot, APIKey];
	NSURL * URL = [[NSURL alloc] initWithString:URLFormat];
	[URLFormat release];
	
	NSURLRequest * request = [self _requestWithURL:URL];
	[URL release];
	
	return [self _connectionWithRequest:request type:TIReachEngineConnectionTypeGameMetadata];
}

- (TIReachEngineConnection *)getGamesforPlayer:(NSString *)gamertag ofGameType:(NSString *)gameType forPage:(NSInteger)page {
	
	if (gamertag && gameType){
		
		NSString * gamertagParam = [[gamertag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
					stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		NSString * URLFormat = [[NSString alloc] initWithFormat:@"%@player/gamehistory/%@/%@/%@/%i", APIRoot, APIKey, gamertagParam, gameType, page];
		NSURL * URL = [[NSURL alloc] initWithString:URLFormat];
		[URLFormat release];
		
		NSURLRequest * request = [self _requestWithURL:URL];
		[URL release];
		
		TIReachEngineConnection * connection = [self _connectionWithRequest:request type:TIReachEngineConnectionTypeGameHistory];
		
		NSArray * objectsArray = [[NSArray alloc] initWithObjects:gamertag, gameType, [NSNumber numberWithInteger:page], nil];
		NSArray * keysArray = [[NSArray alloc] initWithObjects:TIReachEngineConnectionGamertagKey, 
							   TIReachEngineConnectionGameTypeKey, TIReachEngineConnectionPageNumberKey, nil];
		
		NSDictionary * userInfo = [[NSDictionary alloc] initWithObjects:objectsArray forKeys:keysArray];
		[objectsArray release];
		[keysArray release];
		
		[connection setUserInfo:userInfo];
		[userInfo release];
		
		return connection;
	}
	
	return nil;
}

- (TIReachEngineConnection *)getGameDetailsForGameID:(NSString *)gameID {
	
	if (gameID){
		
		NSString * URLFormat = [[NSString alloc] initWithFormat:@"%@game/details/%@/%@", APIRoot, APIKey, gameID];
		NSURL * URL = [[NSURL alloc] initWithString:URLFormat];
		[URLFormat release];
		
		NSURLRequest * request = [self _requestWithURL:URL];
		[URL release];
		
		TIReachEngineConnection * connection = [self _connectionWithRequest:request type:TIReachEngineConnectionTypeGameDetails];
		
		NSDictionary * userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:gameID, TIReachEngineConnectionSearchIDKey, nil];
		[connection setUserInfo:userInfo];
		[userInfo release];
		
		return connection;
	}
	
	return nil;
	
}

- (TIReachEngineConnection *)getPlayerDetails:(NSString *)gamertag withStatsType:(NSString *)statsType {
	
	if (gamertag && statsType){
		
		NSString * gamertagParam = [[gamertag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
					stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		NSString * URLFormat = [[NSString alloc] initWithFormat:@"%@player/details/%@/%@/%@", APIRoot, statsType, APIKey, gamertagParam];
		NSURL * URL = [[NSURL alloc] initWithString:URLFormat];
		[URLFormat release];
		
		NSURLRequest * request = [self _requestWithURL:URL];
		[URL release];
		
		TIReachEngineConnection * connection = [self _connectionWithRequest:request type:TIReachEngineConnectionTypePlayerDetails];
		
		NSDictionary * userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:gamertag, TIReachEngineConnectionGamertagKey, nil];
		[connection setUserInfo:userInfo];
		[userInfo release];
		
		return connection;
	}
	
	return nil;
}

- (TIReachEngineConnection *)getFileShareForPlayer:(NSString *)gamertag {
	
	if (gamertag){
		
		NSString * gamertagParam = [[gamertag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
					stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		NSString * URLFormat = [[NSString alloc] initWithFormat:@"%@file/share/%@/%@", APIRoot, APIKey, gamertagParam];
		NSURL * URL = [[NSURL alloc] initWithString:URLFormat];
		[URLFormat release];
		
		NSURLRequest * request = [self _requestWithURL:URL];
		[URL release];
		
		TIReachEngineConnection * connection = [self _connectionWithRequest:request type:TIReachEngineConnectionTypePlayerFileShare];
		
		NSDictionary * userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:gamertag, TIReachEngineConnectionGamertagKey, nil];
		[connection setUserInfo:userInfo];
		[userInfo release];
		
		return connection;
	}
	
	return nil;
}

- (TIReachEngineConnection *)getFileDetailsForFileID:(NSString *)fileID {
	
	if (fileID){
		
		NSString * URLFormat = [[NSString alloc] initWithFormat:@"%@file/details/%@/%@", APIRoot, APIKey, fileID];
		NSURL * URL = [[NSURL alloc] initWithString:URLFormat];
		[URLFormat release];
		
		NSURLRequest * request = [self _requestWithURL:URL];
		[URL release];
		
		TIReachEngineConnection * connection = [self _connectionWithRequest:request type:TIReachEngineConnectionTypeFileDetails];
		
		NSDictionary * userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:fileID, TIReachEngineConnectionSearchIDKey, nil];
		[connection setUserInfo:userInfo];
		[userInfo release];
		
		return connection;
	}
	
	return nil;
}

- (TIReachEngineConnection *)getFileSetsForPlayer:(NSString *)gamertag {
	
	if (gamertag){
		
		NSString * gamertagParam = [[gamertag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
					stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		NSString * URLFormat = [[NSString alloc] initWithFormat:@"%@file/sets/%@/%@", APIRoot, APIKey, gamertagParam];
		NSURL * URL = [[NSURL alloc] initWithString:URLFormat];
		[URLFormat release];
		
		NSURLRequest * request = [self _requestWithURL:URL];
		[URL release];
		
		TIReachEngineConnection * connection = [self _connectionWithRequest:request type:TIReachEngineConnectionTypePlayerFileSets];
		
		NSDictionary * userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:gamertag, TIReachEngineConnectionGamertagKey, nil];
		[connection setUserInfo:userInfo];
		[userInfo release];
		
		return connection;
	}
	
	return nil;
	
}
- (TIReachEngineConnection *)getFilesForFileSetID:(NSString *)fileSetID player:(NSString *)gamertag {
	
	if (fileSetID && gamertag){
		
		NSString * gamertagParam = [[gamertag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
					stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		NSString * URLFormat = [[NSString alloc] initWithFormat:@"%@file/sets/files/%@/%@/%@", APIRoot, APIKey,gamertagParam, fileSetID];
		NSURL * URL = [[NSURL alloc] initWithString:URLFormat];
		[URLFormat release];
		
		NSURLRequest * request = [self _requestWithURL:URL];
		[URL release];
		
		TIReachEngineConnection * connection = [self _connectionWithRequest:request type:TIReachEngineConnectionTypePlayerFileSetFiles];
		
		NSArray * objectsArray = [[NSArray alloc] initWithObjects:fileSetID, gamertag, nil];
		NSArray * keysArray = [[NSArray alloc] initWithObjects:TIReachEngineConnectionSearchIDKey, 
							   TIReachEngineConnectionGamertagKey, nil];
		
		NSDictionary * userInfo = [[NSDictionary alloc] initWithObjects:objectsArray forKeys:keysArray];
		[objectsArray release];
		[keysArray release];
		
		[connection setUserInfo:userInfo];
		[userInfo release];
		
		return connection;
	}
	
	return nil;
}

- (TIReachEngineConnection *)getRecentScreenshotsForPlayer:(NSString *)gamertag {
	
	if (gamertag){
		
		NSString * gamertagParam = [[gamertag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
					stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		NSString * URLFormat = [[NSString alloc] initWithFormat:@"%@file/screenshots/%@/%@", APIRoot, APIKey, gamertagParam];
		NSURL * URL = [[NSURL alloc] initWithString:URLFormat];
		[URLFormat release];
		
		NSURLRequest * request = [self _requestWithURL:URL];
		[URL release];
		
		TIReachEngineConnection * connection = [self _connectionWithRequest:request type:TIReachEngineConnectionTypePlayerScreenshots];
		
		NSDictionary * userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:gamertag, TIReachEngineConnectionGamertagKey, nil];
		[connection setUserInfo:userInfo];
		[userInfo release];
		
		return connection;
	}
	
	return nil;
	
}

- (TIReachEngineConnection *)getRenderedVideosForPlayer:(NSString *)gamertag page:(NSInteger)page {
	
	if (gamertag){
		
		NSString * gamertagParam = [[gamertag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
					stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		NSString * URLFormat = [[NSString alloc] initWithFormat:@"%@file/videos/%@/%@/%i", APIRoot, APIKey, gamertagParam, page];
		NSURL * URL = [[NSURL alloc] initWithString:URLFormat];
		[URLFormat release];
		
		NSURLRequest * request = [self _requestWithURL:URL];
		[URL release];
		
		TIReachEngineConnection * connection = [self _connectionWithRequest:request type:TIReachEngineConnectionTypePlayerRenderedVideos];
		
		NSArray * objectsArray = [[NSArray alloc] initWithObjects:gamertag, [NSNumber numberWithInteger:page], nil];
		NSArray * keysArray = [[NSArray alloc] initWithObjects:TIReachEngineConnectionGamertagKey, 
							   TIReachEngineConnectionPageNumberKey, nil];
		
		NSDictionary * userInfo = [[NSDictionary alloc] initWithObjects:objectsArray forKeys:keysArray];
		[objectsArray release];
		[keysArray release];
		
		[connection setUserInfo:userInfo];
		[userInfo release];
		
		return connection;
	}
	
	return nil;
}

- (TIReachEngineConnection *)getResultsForSearch:(TIReachEngineSearch *)search {
	
	if (search){
		
		NSString * URLFormat = [[NSString alloc] initWithFormat:@"%@file/search/%@/%@", APIRoot, APIKey, [search safeURLRepresentation]];
		NSURL * URL = [[NSURL alloc] initWithString:URLFormat];
		[URLFormat release];
		
		NSURLRequest * request = [self _requestWithURL:URL];
		[URL release];
		
		TIReachEngineConnection * connection = [self _connectionWithRequest:request type:TIReachEngineConnectionTypeFileSearch];
		
		NSDictionary * userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:search, TIReachEngineConnectionSearchQueryKey, nil];
		[connection setUserInfo:userInfo];
		[userInfo release];
		
		return connection;
	}
	
	return nil;
}

- (TIReachEngineConnection *)getChallenges {
	
	NSString * URLFormat = [[NSString alloc] initWithFormat:@"%@game/challenges/%@", APIRoot, APIKey];
	NSURL * URL = [[NSURL alloc] initWithString:URLFormat];
	[URLFormat release];
	
	NSURLRequest * request = [self _requestWithURL:URL];
	[URL release];
	
	return [self _connectionWithRequest:request type:TIReachEngineConnectionTypeChallenges];
}

#pragma mark Connection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
	NSMutableDictionary * newUserInfo = [[NSMutableDictionary alloc] initWithDictionary:[(TIReachEngineConnection *)connection userInfo]];
	
	if ([newUserInfo objectForKey:TIReachEngineConnectionResponseStatusCodeKey]){
		[newUserInfo removeObjectForKey:TIReachEngineConnectionResponseStatusCodeKey];
	}
	
	[newUserInfo setObject:[NSNumber numberWithInteger:[(NSHTTPURLResponse *)response statusCode]] forKey:TIReachEngineConnectionResponseStatusCodeKey];
	[(TIReachEngineConnection *)connection setUserInfo:newUserInfo];
	[newUserInfo release];
	
	[(NSMutableData *)[returnDataDict objectForKey:[NSValue valueWithPointer:connection]] setLength:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	if ([delegate respondsToSelector:@selector(reachEngine:connection:didFailWithError:)]){
		[delegate reachEngine:self connection:(TIReachEngineConnection *)connection didFailWithError:error];
	}
	
	[returnDataDict removeObjectForKey:[NSValue valueWithPointer:connection]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	[(NSMutableData *)[returnDataDict objectForKey:[NSValue valueWithPointer:connection]] appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	TIReachEngineConnection * correctCon = (TIReachEngineConnection *)connection;
	NSInteger statusCode = [(NSNumber *)[correctCon.userInfo objectForKey:TIReachEngineConnectionResponseStatusCodeKey] intValue];
	
	NSString * stringResponse = [[[NSString alloc] initWithData:[returnDataDict objectForKey:[NSValue valueWithPointer:connection]] 
													   encoding:NSUTF8StringEncoding] autorelease];
	[returnDataDict removeObjectForKey:[NSValue valueWithPointer:connection]];
	
	if (statusCode != 200){
		
		NSString * errorString = [NSString stringWithFormat:@"Server returned status code %i", statusCode];
		NSDictionary * errorDict = [NSDictionary dictionaryWithObject:errorString forKey:NSLocalizedDescriptionKey];
		NSError * error = [NSError errorWithDomain:ERROR_DOMAIN code:statusCode userInfo:errorDict];
		
		[self _notifyDelegateOfError:error forConnection:correctCon];
		return;
	}
	
	NSDictionary * results = [stringResponse JSONValue];
	
	if (correctCon.connectionType == TIReachEngineConnectionTypeGameMetadata){
		[self _notifyDelegateOfMetadata:results forConnection:correctCon];
	}
	
	if (correctCon.connectionType == TIReachEngineConnectionTypeGameHistory){
		[self _notifyDelegateOfGames:results forConnection:correctCon];
	}
	
	if (correctCon.connectionType == TIReachEngineConnectionTypeGameDetails){
		[self _notifyDelegateOfGameDetails:results forConnection:correctCon];
	}
	
	if (correctCon.connectionType == TIReachEngineConnectionTypePlayerDetails){
		[self _notifyDelegateOfPlayerDetails:results forConnection:correctCon];
	}
	
	if (correctCon.connectionType == TIReachEngineConnectionTypePlayerFileShare){
		[self _notifyDelegateOfFileShare:results forConnection:correctCon];
	}
	
	if (correctCon.connectionType == TIReachEngineConnectionTypeFileDetails){
		[self _notifyDelegateOfFileDetails:results forConnection:correctCon];
	}
	
	if (correctCon.connectionType == TIReachEngineConnectionTypePlayerFileSets){
		[self _notifyDelegateOfFileSets:results forConnection:correctCon];
	}
	
	if (correctCon.connectionType == TIReachEngineConnectionTypePlayerFileSetFiles){
		[self _notifyDelegateOfFileSetFiles:results forConnection:correctCon];
	}
	
	if (correctCon.connectionType == TIReachEngineConnectionTypePlayerScreenshots){
		[self _notifyDelegateOfScreenshots:results forConnection:correctCon];
	}
	
	if (correctCon.connectionType == TIReachEngineConnectionTypePlayerRenderedVideos){
		[self _notifyDelegateOfRenderedVideos:results forConnection:correctCon];
	}
	
	if (correctCon.connectionType == TIReachEngineConnectionTypeFileSearch){
		[self _notifyDelegateOfSearchResults:results forConnection:correctCon];
	}
	
	if (correctCon.connectionType == TIReachEngineConnectionTypeChallenges){
		[self _notifyDelegateOfChallenges:results forConnection:correctCon];
	}
}

#pragma mark -
#pragma mark Private Convienience Methods
- (NSMutableURLRequest *)_requestWithURL:(NSURL *)URL {
	return [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
}
								  
- (TIReachEngineConnection *)_connectionWithRequest:(NSURLRequest *)request type:(TIReachEngineConnectionType)type {
	
	TIReachEngineConnection * connection = [[TIReachEngineConnection alloc] initWithRequest:request delegate:self];
	[connection setConnectionType:type];
	
	if (connection){
		NSMutableData * data = [[NSMutableData alloc] init];
		[returnDataDict setObject:data forKey:[NSValue valueWithPointer:connection]];
		[data release];
	}
	
	[connection release];
	
	return connection;
}

#pragma mark Private Delegate Notifiers
- (void)_notifyDelegateOfError:(NSError *)error forConnection:(TIReachEngineConnection *)connection {
	
	if ([delegate respondsToSelector:@selector(reachEngine:connection:didFailWithError:)]){
		[delegate reachEngine:self connection:connection didFailWithError:error];
	}
}

- (void)_notifyDelegateOfMetadata:(NSDictionary *)metadata forConnection:(TIReachEngineConnection *)connection {
	
	if ([delegate respondsToSelector:@selector(reachEngine:didReceiveMetadata:forConnection:)]){
		[delegate reachEngine:self didReceiveMetadata:metadata forConnection:connection];
	}
}

- (void)_notifyDelegateOfGames:(NSDictionary *)games forConnection:(TIReachEngineConnection *)connection {
	
	if ([delegate respondsToSelector:@selector(reachEngine:didReceiveGames:forPlayer:ofGameType:forPage:connection:)]){
		[delegate reachEngine:self 
			  didReceiveGames:games
				  forPlayer:[connection.userInfo objectForKey:TIReachEngineConnectionGamertagKey] 
				 ofGameType:[connection.userInfo objectForKey:TIReachEngineConnectionGameTypeKey] 
					   forPage:[[connection.userInfo objectForKey:TIReachEngineConnectionPageNumberKey] integerValue]
				   connection:connection];
	}
}

- (void)_notifyDelegateOfGameDetails:(NSDictionary *)details forConnection:(TIReachEngineConnection *)connection {
	
	if ([delegate respondsToSelector:@selector(reachEngine:didReceiveGameDetails:forGameID:connection:)]){
		[delegate reachEngine:self 
		didReceiveGameDetails:details 
					forGameID:[connection.userInfo objectForKey:TIReachEngineConnectionSearchIDKey] 
				   connection:connection];
	}
}

- (void)_notifyDelegateOfPlayerDetails:(NSDictionary *)details forConnection:(TIReachEngineConnection *)connection {
	
	if ([delegate respondsToSelector:@selector(reachEngine:didReceivePlayerDetails:forPlayer:connection:)]){
		[delegate reachEngine:self 
	  didReceivePlayerDetails:details 
					forPlayer:[connection.userInfo objectForKey:TIReachEngineConnectionGamertagKey] 
				   connection:connection];
	}
}

- (void)_notifyDelegateOfFileShare:(NSDictionary *)fileShare forConnection:(TIReachEngineConnection *)connection {
	
	if ([delegate respondsToSelector:@selector(reachEngine:didReceiveFileShare:forPlayer:connection:)]){
		[delegate reachEngine:self 
		  didReceiveFileShare:fileShare 
					forPlayer:[connection.userInfo objectForKey:TIReachEngineConnectionGamertagKey] 
				   connection:connection];
	}
}

- (void)_notifyDelegateOfFileDetails:(NSDictionary *)details forConnection:(TIReachEngineConnection *)connection {
	
	if ([delegate respondsToSelector:@selector(reachEngine:didReceiveFileDetails:forFileID:connection:)]){
		[delegate reachEngine:self 
		didReceiveFileDetails:details 
					forFileID:[connection.userInfo objectForKey:TIReachEngineConnectionSearchIDKey] 
				   connection:connection];
	}
}

- (void)_notifyDelegateOfFileSets:(NSDictionary *)fileSets forConnection:(TIReachEngineConnection *)connection {
	
	if ([delegate respondsToSelector:@selector(reachEngine:didReceiveFileSets:forPlayer:connection:)]){
		[delegate reachEngine:self 
		   didReceiveFileSets:fileSets 
					forPlayer:[connection.userInfo objectForKey:TIReachEngineConnectionGamertagKey] 
				   connection:connection];
	}
	
}

- (void)_notifyDelegateOfFileSetFiles:(NSDictionary *)fileSetFiles forConnection:(TIReachEngineConnection *)connection {
	
	if ([delegate respondsToSelector:@selector(reachEngine:didReceiveFileSetFiles:forFileSetID:player:connection:)]){
		[delegate reachEngine:self 
	   didReceiveFileSetFiles:fileSetFiles 
				 forFileSetID:[connection.userInfo objectForKey:TIReachEngineConnectionSearchIDKey] 
					   player:[connection.userInfo objectForKey:TIReachEngineConnectionGamertagKey] 
				   connection:connection];
	}
}

- (void)_notifyDelegateOfScreenshots:(NSDictionary *)screenshots forConnection:(TIReachEngineConnection *)connection {
	
	if ([delegate respondsToSelector:@selector(reachEngine:didReceiveScreenshots:forPlayer:connection:)]){
		[delegate reachEngine:self 
		didReceiveScreenshots:screenshots 
					forPlayer:[connection.userInfo objectForKey:TIReachEngineConnectionGamertagKey] 
				   connection:connection];
	}
}

- (void)_notifyDelegateOfRenderedVideos:(NSDictionary *)videos forConnection:(TIReachEngineConnection *)connection {
	
	if ([delegate respondsToSelector:@selector(reachEngine:didReceiveRenderedVideos:forPlayer:page:connection:)]){
		[delegate reachEngine:self 
	 didReceiveRenderedVideos:videos
					forPlayer:[connection.userInfo objectForKey:TIReachEngineConnectionGamertagKey] 
						 page:[[connection.userInfo objectForKey:TIReachEngineConnectionPageNumberKey] integerValue]
				   connection:connection];
	}
}

- (void)_notifyDelegateOfSearchResults:(NSDictionary *)results forConnection:(TIReachEngineConnection *)connection {
	
	if ([delegate respondsToSelector:@selector(reachEngine:didReceiveSearchResults:forSearch:connection:)]){
		[delegate reachEngine:self 
	  didReceiveSearchResults:results 
					forSearch:[connection.userInfo objectForKey:TIReachEngineConnectionSearchQueryKey] 
				   connection:connection];
	}
}

- (void)_notifyDelegateOfChallenges:(NSDictionary *)challenges forConnection:(TIReachEngineConnection *)connection {
	
	if ([delegate respondsToSelector:@selector(reachEngine:didReceiveChallenges:forConnection:)]){
		[delegate reachEngine:self didReceiveChallenges:challenges forConnection:connection];
	}
}

#pragma mark -
#pragma mark Memory Management
- (void)dealloc {
	[returnDataDict release];
	[APIRoot release];
	[APIKey release];
	[self setDelegate:nil];
	[super dealloc];
}

@end
